import { describe, expect, it } from 'vitest'
import { localSettingsFromStatus } from './supabase-status.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/6-pr-local-db/spec.md that each test protects.
//
// The values below are made up for the test. They are not the local stack's
// keys and grant nothing anywhere.

const STATUS = [
  'ANON_KEY="made-up-anon"',
  'API_URL="http://127.0.0.1:54321"',
  'DB_URL="postgresql://postgres:postgres@127.0.0.1:54322/postgres"',
  'JWT_SECRET="made-up-jwt"',
  'PUBLISHABLE_KEY="sb_publishable_made_up_for_test"',
  'SECRET_KEY="sb_secret_made_up_for_test"',
  '',
].join('\n')

describe('localSettingsFromStatus', () => {
  it('[prdb 2] takes only the local API address and the local publishable key', () => {
    expect(localSettingsFromStatus(STATUS)).toEqual({
      SUPABASE_URL: 'http://127.0.0.1:54321',
      SUPABASE_PUBLISHABLE_KEY: 'sb_publishable_made_up_for_test',
    })
  })

  it('[prdb 2] reads lines with or without quotes, and Windows line ends', () => {
    const text = 'API_URL=http://localhost:54321\r\nPUBLISHABLE_KEY=sb_publishable_x\r\n'
    expect(localSettingsFromStatus(text)).toEqual({
      SUPABASE_URL: 'http://localhost:54321',
      SUPABASE_PUBLISHABLE_KEY: 'sb_publishable_x',
    })
  })

  it('[prdb 2] never passes on the secret key, the service role key or the JWT secret', () => {
    const values = Object.values(localSettingsFromStatus(STATUS))
    for (const secret of ['made-up-anon', 'made-up-jwt', 'sb_secret_made_up_for_test']) {
      expect(values).not.toContain(secret)
    }
  })

  it('[prdb 2] refuses an address that is not on the runner itself, so the check can never reach a hosted project', () => {
    for (const url of [
      'https://abcdefghijklmnop.supabase.co',
      'http://10.0.0.5:54321',
      'http://127.0.0.1.evil.example:54321',
      'http://localhost.evil.example',
    ]) {
      const text = STATUS.replace('http://127.0.0.1:54321', url)
      expect(() => localSettingsFromStatus(text), url).toThrow(/is not a local address/)
    }
  })

  it('[prdb 2] when a name is missing, the error lists the names it found and no value', () => {
    const text = 'ANON_KEY="made-up-anon"\nAPI_URL="http://127.0.0.1:54321"\n'
    let message = ''
    try {
      localSettingsFromStatus(text)
    } catch (error) {
      message = (error as Error).message
    }
    expect(message).toContain('PUBLISHABLE_KEY')
    expect(message).toContain('ANON_KEY, API_URL')
    expect(message).not.toContain('made-up-anon')
    expect(message).not.toContain('127.0.0.1')
  })

  it('[prdb 2] an address that is not a URL is refused without printing it', () => {
    const text = STATUS.replace('http://127.0.0.1:54321', 'not a url at all')
    expect(() => localSettingsFromStatus(text)).toThrow(/^API_URL is not a local address/)
    expect(() => localSettingsFromStatus(text)).not.toThrow(/not a url at all/)
  })
})
