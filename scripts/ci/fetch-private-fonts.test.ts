import { spawnSync } from 'node:child_process'
import { existsSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { afterEach, describe, expect, it } from 'vitest'
import { install, problems, switzerCss, SWITZER_HASHES } from './fetch-private-fonts.ts'

// The Switzer font files are kept out of the public repository (docs/fonts.md).
// This script puts them in place from a private source. Tests carry [fonts N]:
//   1 without a key or files the script says so and the build can continue
//   2 files that do not match the SHA-256 on record are refused, nothing is written
//   3 the generated CSS loads only from the app's own address, one rule per weight

const dirs: string[] = []
function temp(): string {
  const dir = mkdtempSync(join(tmpdir(), 'fonts-test-'))
  dirs.push(dir)
  return dir
}
afterEach(() => {
  for (const dir of dirs.splice(0)) rmSync(dir, { recursive: true, force: true })
})

function run(env: Record<string, string>) {
  return spawnSync(process.execPath, ['scripts/ci/fetch-private-fonts.ts'], {
    encoding: 'utf8',
    env: { PATH: process.env.PATH ?? '', ...env },
  })
}

describe('fetch-private-fonts', () => {
  it('[fonts 1] with no key, no folder and no files it prints a notice, exits 0 and writes nothing', () => {
    const dest = join(temp(), 'switzer')
    const result = run({ SWITZER_DIR: dest })
    expect(result.status).toBe(0)
    expect(result.stdout).toContain('fallback fonts')
    expect(existsSync(dest)).toBe(false)
  })

  it('[fonts 1] a key that cannot reach the private repository gives a warning, exits 0 and leaves no file', () => {
    const dest = join(temp(), 'switzer')
    const result = run({
      SWITZER_DIR: dest,
      FONTS_DEPLOY_KEY: 'not a real key',
      FONTS_REPO: join(temp(), 'no-such-repository'),
    })
    expect(result.status).toBe(0)
    expect(result.stdout).toContain('fallback fonts')
    expect(result.stdout).not.toContain('not a real key')
    expect(existsSync(dest)).toBe(false)
  })

  it('[fonts 2] files that do not match the SHA-256 on record are refused and nothing is written', () => {
    const source = temp()
    const dest = join(temp(), 'switzer')
    for (const name of Object.keys(SWITZER_HASHES)) writeFileSync(join(source, name), 'made-up content')
    const found = install(source, dest)
    expect(found).toHaveLength(Object.keys(SWITZER_HASHES).length)
    for (const line of found) expect(line).toContain('does not match')
    expect(existsSync(dest)).toBe(false)
    const result = run({ SWITZER_DIR: dest, FONTS_SOURCE_DIR: source })
    expect(result.status).toBe(0)
    expect(result.stdout).toContain('Not installed')
    expect(existsSync(dest)).toBe(false)
  })

  it('[fonts 2] a folder with a missing file is named in the refusal', () => {
    const found = problems(temp())
    expect(found).toContain('Switzer-Regular.woff2 is missing')
    expect(found).toContain('FFL.txt is missing')
  })

  it('[fonts 3] the generated CSS has one rule per weight and asks for no other address', () => {
    const css = switzerCss()
    expect([...css.matchAll(/font-weight: (\d+);/g)].map((m) => m[1])).toEqual(['400', '500', '600', '700'])
    expect(css).toContain("font-family: 'Switzer'")
    expect(css).not.toMatch(/https?:|\/\/|fontshare|italic/)
    for (const [, file] of css.matchAll(/url\('\.\/([^']+)'\)/g))
      expect(Object.keys(SWITZER_HASHES)).toContain(file)
  })
})
