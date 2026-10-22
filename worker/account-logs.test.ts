import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { accountFake } from './account-fakes.ts'
import { handleApi, type ApiDeps } from './api.ts'
import type { FileStore } from './personal-data/file-stores.ts'
import { ENV, cookieHeader, get, post } from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/11-accounts/spec.md that each test protects.
// The Worker never logs an email address, a code, a token or a user id. Every
// console method is watched while learners go through every account route,
// including wrong codes, faults and a failed deletion.

const METHODS = ['log', 'info', 'warn', 'error', 'debug', 'trace'] as const
let written: string[] = []

beforeEach(() => {
  written = []
  for (const method of METHODS) {
    vi.spyOn(console, method).mockImplementation((...args: unknown[]) => {
      written.push(args.map((arg) => (typeof arg === 'string' ? arg : JSON.stringify(arg))).join(' '))
    })
  }
})

afterEach(() => {
  vi.restoreAllMocks()
  vi.useRealTimers()
})

describe('the Worker log during the account routes', () => {
  it('[accounts 26] holds no email address, code, token or user id', async () => {
    const fake = accountFake()
    const owner = fake.addEmailAccount('learner-b@example.com')
    const failing: FileStore = {
      name: 'stand-in',
      exportFor: () => Promise.resolve([]),
      deleteAllFor: () => Promise.reject(new Error('store down')),
    }
    const deps: ApiDeps = { fetch: fake.fetch }
    const send = (path: string, body: unknown, cookie?: string, extra: Partial<ApiDeps> = {}) =>
      handleApi(post(path, { cookie, body: JSON.stringify(body) }), ENV, { ...deps, ...extra })

    // A guest adds a new address: a wrong code, then the right one.
    let guest = cookieHeader(await handleApi(post('/api/guest'), ENV, deps))
    await send('/api/account/email', { email: 'learner-a@example.com' }, guest)
    await send('/api/account/email/verify', { email: 'learner-a@example.com', code: '000001' }, guest)
    const codeA = fake.mail.at(-1)?.code ?? ''
    const added = await send(
      '/api/account/email/verify',
      { email: 'learner-a@example.com', code: codeA },
      guest,
    )
    const deviceA = cookieHeader(added, guest)
    await handleApi(get('/api/me', deviceA), ENV, deps)
    await handleApi(get('/api/account/export', deviceA), ENV, deps)

    // Another guest adds the taken address and switches; one more signs in.
    guest = cookieHeader(await handleApi(post('/api/guest'), ENV, deps))
    await send('/api/account/email', { email: 'learner-b@example.com' }, guest)
    const codeB = fake.mail.at(-1)?.code ?? ''
    await send('/api/account/email/verify', { email: 'learner-b@example.com', code: codeB }, guest, {
      fileStores: [failing],
    })
    const switched = await send(
      '/api/account/email/verify',
      { email: 'learner-b@example.com', code: codeB },
      guest,
    )
    const deviceB = cookieHeader(switched, guest)
    await send('/api/sign-in', { email: 'nobody@example.com' })
    await send('/api/sign-in', { email: 'learner-b@example.com' })
    const codeB2 = fake.mail.at(-1)?.code ?? ''
    await send('/api/sign-in/verify', { email: 'learner-b@example.com', code: '999998' })
    const second = cookieHeader(
      await send('/api/sign-in/verify', { email: 'learner-b@example.com', code: codeB2 }),
    )

    // Sign out, a failed deletion, a deletion, then the other device and Auth down.
    await send('/api/sign-out', {}, second)
    await send('/api/account/delete', {}, deviceA, { fileStores: [failing] })
    await send('/api/account/delete', {}, deviceA)
    await handleApi(get('/api/me', deviceA), ENV, deps)
    await handleApi(get('/api/today', deviceA), ENV, deps)
    await send('/api/account/delete', {}, deviceB)
    fake.down = true
    await send('/api/sign-in', { email: 'learner-b@example.com' })
    await handleApi(get('/api/me', deviceB), ENV, deps)

    const log = written.join('\n')
    const forbidden = [
      ...fake.issued,
      owner.id,
      ...fake.mail.map((m) => m.code),
      ...[deviceA, deviceB, second].flatMap((c) =>
        c.split('; ').map((part) => part.split('=').slice(1).join('=')),
      ),
      'learner-a@example.com',
      'learner-b@example.com',
      'nobody@example.com',
      '000001',
      '999998',
    ].filter(Boolean)
    expect(fake.mail.length).toBeGreaterThan(2)
    expect(forbidden.length).toBeGreaterThan(10)
    for (const value of forbidden) expect(log).not.toContain(value)
    expect(log).not.toMatch(/cookie|authorization|bearer|@example\.com/i)
  })
})
