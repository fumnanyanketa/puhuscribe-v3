import { spawnSync } from 'node:child_process'
import { readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'

// Fast route no-age-limit (owner, 5 November 2026): Aleksi has no age limit.
// [no-age-limit 1] No app text states one. The rendered privacy notice and the
// guest line are checked in src/screens/no-age-limit.test.ts.

const AGE_LIMIT = /18 and over|for adults/i

// Every tracked text file the app or the Worker is built from, tests left out
// (tests may name the old sentence to prove it is gone).
function appTextFiles(): string[] {
  const listed = spawnSync('git', ['ls-files', '-z', 'src', 'worker', 'index.html', 'public'], {
    encoding: 'utf8',
  })
  expect(listed.status).toBe(0)
  return listed.stdout
    .split('\0')
    .filter((path) => /\.(ts|tsx|html|json|css|md|txt)$/.test(path))
    .filter((path) => !/\.test\.ts$|\.spec\.ts$/.test(path))
}

describe('no age limit', () => {
  it('[no-age-limit 1] no app or Worker text file says "18 and over" or "for adults"', () => {
    const files = appTextFiles()
    expect(files.length).toBeGreaterThan(50)
    expect(files).toContain('src/screens/PrivacyPage.tsx')
    expect(files).toContain('src/screens/road-copy.ts')
    expect(files).toContain('src/landing/Landing.tsx')
    const stating = files.filter((path) => AGE_LIMIT.test(readFileSync(path, 'utf8')))
    expect(stating).toEqual([])
  })
})
