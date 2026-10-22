import { afterEach, describe, expect, it, vi } from 'vitest'

// [12] [14] With the Access service token in use, Playwright writes nothing
// that can hold request headers: no trace, no HAR, no HTML report.

async function loadConfig(env: Record<string, string | undefined>) {
  vi.resetModules()
  for (const [name, value] of Object.entries(env)) vi.stubEnv(name, value)
  const mod = (await import('../playwright.config.ts')) as { default: Record<string, unknown> }
  return mod.default as {
    reporter: unknown[]
    use: { trace?: string; recordHar?: unknown; extraHTTPHeaders?: Record<string, string> }
    projects: { use: { trace?: string; recordHar?: unknown } }[]
  }
}

afterEach(() => {
  vi.unstubAllEnvs()
})

describe('playwright.config.ts', () => {
  const token = { CF_ACCESS_CLIENT_ID: 'made-up-id', CF_ACCESS_CLIENT_SECRET: 'made-up-secret', CI: '1' }

  it('[12] turns traces off when the service token headers are set', async () => {
    const config = await loadConfig(token)
    expect(config.use.extraHTTPHeaders).toHaveProperty('CF-Access-Client-Secret')
    expect(config.use.trace).toBe('off')
    for (const project of config.projects) expect(project.use.trace).toBeUndefined()
  })

  it('[12] records no HAR file and writes no HTML report when the headers are set', async () => {
    const config = await loadConfig(token)
    expect(config.use.recordHar).toBeUndefined()
    for (const project of config.projects) expect(project.use.recordHar).toBeUndefined()
    expect(JSON.stringify(config.reporter)).not.toContain('html')
  })

  it('[12] keeps traces for failures when no token is in use', async () => {
    const config = await loadConfig({ CF_ACCESS_CLIENT_ID: undefined, CF_ACCESS_CLIENT_SECRET: undefined })
    expect(config.use.extraHTTPHeaders).toEqual({})
    expect(config.use.trace).toBe('retain-on-failure')
  })

  // Public repository: the CI jobs that fetch the private Switzer font files set
  // PUHUSCRIBE_NO_TRACE=1, because a trace or HTML report holds every file the
  // page loaded, fonts included.
  it('[public 1] turns traces off and writes no HTML report when PUHUSCRIBE_NO_TRACE is 1, with no token', async () => {
    const config = await loadConfig({
      CF_ACCESS_CLIENT_ID: undefined,
      CF_ACCESS_CLIENT_SECRET: undefined,
      CI: '1',
      PUHUSCRIBE_NO_TRACE: '1',
    })
    expect(config.use.extraHTTPHeaders).toEqual({})
    expect(config.use.trace).toBe('off')
    expect(JSON.stringify(config.reporter)).not.toContain('html')
  })

  it('[public 1] still writes the HTML report in CI when neither the token nor PUHUSCRIBE_NO_TRACE is set', async () => {
    const config = await loadConfig({
      CF_ACCESS_CLIENT_ID: undefined,
      CF_ACCESS_CLIENT_SECRET: undefined,
      CI: '1',
      PUHUSCRIBE_NO_TRACE: undefined,
    })
    expect(JSON.stringify(config.reporter)).toContain('html')
    expect(config.use.trace).toBe('retain-on-failure')
  })
})
