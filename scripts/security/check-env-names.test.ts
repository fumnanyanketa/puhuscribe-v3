import { spawnSync } from 'node:child_process'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'

// [8] The build stops before Vite runs when a secret looking variable carries
// the VITE_ prefix (Vite ships VITE_ variables to the browser).

const CHECKER = join(import.meta.dirname, 'check-env-names.ts')

function run(env: Record<string, string>) {
  return spawnSync(process.execPath, [CHECKER], { encoding: 'utf8', env: { ...process.env, ...env } })
}

describe('check-env-names', () => {
  it('[8] passes when no VITE_ variable looks secret', () => {
    expect(run({ VITE_APP_NAME: 'PuhuScribe' }).status).toBe(0)
  })

  it.each(['VITE_SUPABASE_KEY', 'VITE_CLIENT_SECRET', 'VITE_API_TOKEN', 'VITE_DB_PASSWORD'])(
    '[8] fails when %s is set',
    (name) => {
      const result = run({ [name]: 'x' })
      expect(result.status).toBe(1)
      expect(result.stderr).toContain(name)
    },
  )
})
