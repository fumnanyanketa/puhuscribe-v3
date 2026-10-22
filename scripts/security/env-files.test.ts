import { mkdtempSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { basename, join } from 'node:path'
import { afterEach, describe, expect, it } from 'vitest'
import { localEnvFiles } from './env-files.ts'

// [14] The secret checks read the local test settings, and never open the
// owner's Cloudflare account file or the names-only example.

const dirs: string[] = []
afterEach(() => {
  for (const dir of dirs.splice(0)) rmSync(dir, { recursive: true, force: true })
})

describe('localEnvFiles', () => {
  it('[14] lists .env.local and .dev.vars but never .env.cloudflare or .env.example', () => {
    const dir = mkdtempSync(join(tmpdir(), 'puhuscribe-env-'))
    dirs.push(dir)
    for (const name of ['.env.local', '.dev.vars', '.env.cloudflare', '.env.example', 'README.md']) {
      writeFileSync(join(dir, name), '')
    }
    expect(
      localEnvFiles(dir)
        .map((p) => basename(p))
        .sort(),
    ).toEqual(['.dev.vars', '.env.local'])
  })
})
