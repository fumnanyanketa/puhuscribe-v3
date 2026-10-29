import { afterEach, describe, expect, it, vi } from 'vitest'
import { CODE_SENT_ANSWER } from '../src/lib/account-types.ts'
import { USER_TABLE_NAMES } from '../src/privacy/data-inventory.ts'
import { accountFake, type AccountFake } from './account-fakes.ts'
import { handleApi, type ApiDeps } from './api.ts'
import { AUTH_COOKIE, learnerContext } from './learner-auth.ts'
import { AccountGone, supabaseLearnerDb } from './learner-db.ts'
import type { FileStore } from './personal-data/file-stores.ts'
import { ENV, ORIGIN, cookieHeader, fakeSupabase, get, post, setCookies } from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/11-accounts/spec.md that each test protects.
// The account routes, with a fake Supabase (worker/account-fakes.ts).

afterEach(() => {
  vi.useRealTimers()
})

const A = 'learner-a@example.com'
const B = 'learner-b@example.com'

function depsOf(fake: AccountFake, extra: Partial<ApiDeps> = {}): ApiDeps {
  return { fetch: fake.fetch, ...extra }
}

function call(fake: AccountFake, request: Request, extra: Partial<ApiDeps> = {}) {
  return handleApi(request, ENV, depsOf(fake, extra))
}

function postJson(path: string, body: unknown, cookie?: string) {
  return post(path, { cookie, body: JSON.stringify(body) })
}

/** A new guest (job 8's Start), as a cookie header. */
async function newGuest(fake: AccountFake): Promise<string> {
  const res = await call(fake, post('/api/guest'))
  expect(res.status).toBe(201)
  return cookieHeader(res)
}

function guestIdOf(fake: AccountFake): string {
  const guests = [...fake.users.values()].filter((u) => u.isAnonymous)
  return guests.at(-1)?.id ?? ''
}

function lastMailTo(fake: AccountFake, to: string) {
  const mail = fake.mail.filter((m) => m.to === to).at(-1)
  if (!mail) throw new Error('No mail to that address.')
  return mail
}

/** Signs a device in to an existing email account through the routes. */
async function signedInDevice(fake: AccountFake, email: string, cookie = ''): Promise<string> {
  const sent = await call(fake, postJson('/api/sign-in', { email }, cookie || undefined))
  expect(sent.status).toBe(200)
  const code = lastMailTo(fake, email).code
  const res = await call(fake, postJson('/api/sign-in/verify', { email, code }, cookie || undefined))
  expect(res.status).toBe(200)
  return cookieHeader(res, cookie)
}

async function me(fake: AccountFake, cookie: string) {
  const res = await call(fake, get('/api/me', cookie))
  return { status: res.status, body: await res.json<Record<string, unknown>>(), res }
}

describe('GET /api/me', () => {
  it('[accounts 3] without a sign in it answers kind none and asks Supabase nothing', async () => {
    const fake = accountFake()
    const res = await call(fake, get('/api/me'))
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ kind: 'none' })
    expect(fake.requests).toEqual([])
  })

  it('[accounts 3] a guest is "guest", learned from my_account in the database, never from Auth /user', async () => {
    const fake = accountFake()
    const cookie = await newGuest(fake)
    fake.requests.length = 0
    const { status, body, res } = await me(fake, cookie)
    expect(status).toBe(200)
    expect(body).toEqual({ kind: 'guest' })
    expect(fake.requests.map((r) => r.url.pathname)).toEqual(['/rest/v1/rpc/my_account'])
    expect(setCookies(res)).toEqual([])
  })

  it('[accounts 3] an email account is "email" with its address, and no token or user id', async () => {
    const fake = accountFake()
    const user = fake.addEmailAccount(B)
    const cookie = await signedInDevice(fake, B)
    const res = await call(fake, get('/api/me', cookie))
    const text = await res.text()
    expect(JSON.parse(text)).toEqual({ kind: 'email', email: B })
    expect(text).not.toContain(user.id)
    for (const value of fake.issued) expect(text).not.toContain(value)
  })

  it('[accounts 3] [accounts 22] a signed out sign in (its session row gone) answers 401 and clears the cookies', async () => {
    const fake = accountFake()
    fake.addEmailAccount(B)
    const cookie = await signedInDevice(fake, B)
    fake.sessions.clear()
    const { status, body, res } = await me(fake, cookie)
    expect(status).toBe(401)
    expect(body).toEqual({ error: 'session_ended', account: 'email' })
    expect(cookieHeader(res, cookie)).toBe('')
  })
})

describe('adding an email to a guest', () => {
  it('[accounts 4] an empty, too long or badly shaped address is refused gently, and Supabase is not asked', async () => {
    const fake = accountFake()
    const cookie = await newGuest(fake)
    fake.requests.length = 0
    for (const email of [
      '',
      '   ',
      'learner',
      'learner@',
      '@example.com',
      'a b@example.com',
      `${'a'.repeat(243)}@example.com`,
      42,
    ]) {
      const res = await call(fake, postJson('/api/account/email', { email }, cookie))
      expect(res.status, String(email)).toBe(400)
      expect(await res.json()).toEqual({ error: 'bad_email' })
    }
    expect(fake.requests).toEqual([])
    expect(fake.mail).toEqual([])
  })

  it('[accounts 4] [accounts 7] a new address gets a code email, and the account stays a guest with no email until the code', async () => {
    const fake = accountFake()
    const cookie = await newGuest(fake)
    const res = await call(fake, postJson('/api/account/email', { email: ` ${A.toUpperCase()} ` }, cookie))
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual(CODE_SENT_ANSWER)
    expect(fake.mail).toEqual([
      { to: A, code: expect.stringMatching(/^\d{6}$/) as unknown, kind: 'email_change' },
    ])
    const user = fake.users.get(guestIdOf(fake))
    expect(user?.isAnonymous).toBe(true)
    expect(user?.email).toBeNull()
  })

  it('[accounts 4] only a guest may add an email: an email account gets 409 and nothing is sent', async () => {
    const fake = accountFake()
    fake.addEmailAccount(B)
    const cookie = await signedInDevice(fake, B)
    const mails = fake.mail.length
    const res = await call(fake, postJson('/api/account/email', { email: A }, cookie))
    expect(res.status).toBe(409)
    expect(await res.json()).toEqual({ error: 'has_email' })
    expect(fake.mail.length).toBe(mails)
    expect(fake.requests.filter((r) => r.url.pathname === '/auth/v1/user' && r.method === 'PUT')).toEqual([])
  })

  it('[accounts 4] without a sign in it answers 401 and sends nothing', async () => {
    const fake = accountFake()
    const res = await call(fake, postJson('/api/account/email', { email: A }))
    expect(res.status).toBe(401)
    expect(fake.mail).toEqual([])
  })

  it('[accounts 5] [accounts 7] a wrong code changes nothing: still a guest with no email, same cookies', async () => {
    const fake = accountFake()
    const cookie = await newGuest(fake)
    await call(fake, postJson('/api/account/email', { email: A }, cookie))
    const right = lastMailTo(fake, A).code
    const wrong = right === '000000' ? '111111' : '000000'
    for (const code of [wrong, '12345', 'abcdef']) {
      const res = await call(fake, postJson('/api/account/email/verify', { email: A, code }, cookie))
      expect(res.status, code).toBe(400)
      expect(await res.json()).toEqual({ error: 'wrong_code' })
      expect(setCookies(res)).toEqual([])
    }
    const user = fake.users.get(guestIdOf(fake))
    expect(user?.isAnonymous).toBe(true)
    expect(user?.email).toBeNull()
    expect((await me(fake, cookie)).body).toEqual({ kind: 'guest' })
  })

  it('[accounts 6] the right code keeps the same account: same user id, no longer a guest, with the email', async () => {
    const fake = accountFake()
    const cookie = await newGuest(fake)
    const guestId = guestIdOf(fake)
    const oldSessions = [...fake.sessions.keys()]
    await call(fake, postJson('/api/account/email', { email: A }, cookie))
    const res = await call(
      fake,
      postJson('/api/account/email/verify', { email: A, code: lastMailTo(fake, A).code }, cookie),
    )
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ result: 'added' })
    expect(fake.users.size).toBe(1)
    const user = fake.users.get(guestId)
    expect(user?.email).toBe(A)
    expect(user?.isAnonymous).toBe(false)
    const after = cookieHeader(res, cookie)
    expect(after).toContain(AUTH_COOKIE)
    expect((await me(fake, after)).body).toEqual({ kind: 'email', email: A })
    // The guest's old sign in on this device was ended; the new one replaces it.
    for (const sid of oldSessions) expect(fake.sessions.has(sid)).toBe(false)
    expect(fake.events).toContain('logout:local')
  })

  it('[accounts 8] a taken address: the account that has it gets a sign in code instead, and no email change is made', async () => {
    const fake = accountFake()
    fake.addEmailAccount(B)
    const cookie = await newGuest(fake)
    const res = await call(fake, postJson('/api/account/email', { email: B }, cookie))
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual(CODE_SENT_ANSWER)
    expect(fake.mail).toEqual([
      { to: B, code: expect.stringMatching(/^\d{6}$/) as unknown, kind: 'magic_link' },
    ])
    const otp = fake.requests.find((r) => r.url.pathname === '/auth/v1/otp')
    expect(JSON.parse(otp?.body ?? '{}')).toMatchObject({ email: B, create_user: false })
    expect(fake.users.get(guestIdOf(fake))?.pending).toBeNull()
  })

  it('[accounts 8] [accounts 23] its code signs the device in to that account, deletes the guest (files first), and leaves the account unchanged', async () => {
    const fake = accountFake()
    const owner = fake.addEmailAccount(B)
    fake.data.set(owner.id, { sessions: [{ id: 'b-session' }] })
    const cookie = await newGuest(fake)
    const guestId = guestIdOf(fake)
    const store: FileStore = {
      name: 'stand-in',
      exportFor: () => Promise.resolve([]),
      deleteAllFor: (who) => {
        fake.events.push(`files:${who.userId === guestId ? 'guest' : 'other'}`)
        return Promise.resolve()
      },
    }
    await call(fake, postJson('/api/account/email', { email: B }, cookie))
    fake.events.length = 0
    const res = await call(
      fake,
      postJson('/api/account/email/verify', { email: B, code: lastMailTo(fake, B).code }, cookie),
      { fileStores: [store] },
    )
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ result: 'switched' })
    expect(fake.users.has(guestId)).toBe(false)
    expect(fake.users.get(owner.id)?.email).toBe(B)
    expect(fake.data.get(owner.id)).toEqual({ sessions: [{ id: 'b-session' }] })
    const order = fake.events.filter((e) => e.startsWith('files:') || e === 'rpc:delete_my_account')
    expect(order).toEqual(['files:guest', 'rpc:delete_my_account'])
    const after = cookieHeader(res, cookie)
    expect((await me(fake, after)).body).toEqual({ kind: 'email', email: B })
  })

  it('[accounts 8] [accounts 23] if the guest cannot be deleted, the device stays the guest and the new sign in is ended', async () => {
    const fake = accountFake()
    fake.addEmailAccount(B)
    const cookie = await newGuest(fake)
    const guestId = guestIdOf(fake)
    await call(fake, postJson('/api/account/email', { email: B }, cookie))
    const sessionsBefore = fake.sessions.size
    const failing: FileStore = {
      name: 'stand-in',
      exportFor: () => Promise.resolve([]),
      deleteAllFor: () => Promise.reject(new Error('store down')),
    }
    const res = await call(
      fake,
      postJson('/api/account/email/verify', { email: B, code: lastMailTo(fake, B).code }, cookie),
      { fileStores: [failing] },
    )
    expect(res.status).toBe(503)
    expect(fake.users.has(guestId)).toBe(true)
    expect(fake.sessions.size).toBe(sessionsBefore)
    expect(setCookies(res)).toEqual([])
    expect((await me(fake, cookie)).body).toEqual({ kind: 'guest' })
  })
})

describe('the answer never tells whether an address has an account', () => {
  it('[accounts 9] new, taken and unknown addresses get the same status, body and cookies, byte for byte', async () => {
    const fake = accountFake()
    fake.addEmailAccount(B)
    const answers: { status: number; text: string; cookies: string[] }[] = []
    const read = async (res: Response) => {
      answers.push({ status: res.status, text: await res.text(), cookies: setCookies(res) })
    }
    // A guest adds a new address, then another guest adds a taken one.
    await read(await call(fake, postJson('/api/account/email', { email: A }, await newGuest(fake))))
    await read(await call(fake, postJson('/api/account/email', { email: B }, await newGuest(fake))))
    // Sign in with an existing and with an unknown address, with and without a guest.
    await read(await call(fake, postJson('/api/sign-in', { email: B })))
    await read(await call(fake, postJson('/api/sign-in', { email: 'nobody@example.com' })))
    await read(await call(fake, postJson('/api/sign-in', { email: B }, await newGuest(fake))))
    await read(
      await call(fake, postJson('/api/sign-in', { email: 'nobody@example.com' }, await newGuest(fake))),
    )
    expect(answers).toHaveLength(6)
    for (const one of answers) {
      expect(one).toEqual({ status: 200, text: JSON.stringify(CODE_SENT_ANSWER), cookies: [] })
    }
  })

  it('[accounts 9] a rate limited address gets the same answer too', async () => {
    const fake = accountFake()
    const limited: ApiDeps['fetch'] = async (input, init) => {
      const url = new URL(new Request(input, init).url)
      if (url.pathname === '/auth/v1/otp') {
        return new Response(JSON.stringify({ code: 'over_email_send_rate_limit', msg: 'too many' }), {
          status: 429,
          headers: { 'content-type': 'application/json' },
        })
      }
      return fake.fetch(input, init)
    }
    const res = await handleApi(postJson('/api/sign-in', { email: B }), ENV, { fetch: limited })
    expect(res.status).toBe(200)
    expect(await res.text()).toBe(JSON.stringify(CODE_SENT_ANSWER))
  })

  it('[accounts 9] when Supabase is down the answer is a fault for every address alike', async () => {
    const fake = accountFake()
    fake.down = true
    const res = await call(fake, postJson('/api/sign-in', { email: B }))
    expect(res.status).toBe(503)
    expect(await res.json()).toEqual({ error: 'not_available' })
  })
})

describe('signing in on another device', () => {
  it('[accounts 10] asks Supabase for a code with shouldCreateUser false, and the code sets HttpOnly, Secure, SameSite=Lax cookies', async () => {
    const fake = accountFake()
    const user = fake.addEmailAccount(B)
    const sent = await call(fake, postJson('/api/sign-in', { email: B }))
    expect(await sent.json()).toEqual(CODE_SENT_ANSWER)
    const otp = fake.requests.find((r) => r.url.pathname === '/auth/v1/otp')
    expect(JSON.parse(otp?.body ?? '{}')).toMatchObject({ email: B, create_user: false })
    const res = await call(
      fake,
      postJson('/api/sign-in/verify', { email: B, code: lastMailTo(fake, B).code }),
    )
    expect(res.status).toBe(200)
    const text = await res.text()
    expect(JSON.parse(text)).toEqual({ result: 'signed_in' })
    for (const value of fake.issued) expect(text).not.toContain(value)
    expect(text).not.toContain(user.id)
    const cookies = setCookies(res)
    expect(cookies.length).toBeGreaterThan(0)
    for (const cookie of cookies) {
      expect(cookie.startsWith(AUTH_COOKIE)).toBe(true)
      expect(cookie).toMatch(/;\s*HttpOnly/i)
      expect(cookie).toMatch(/;\s*Secure/i)
      expect(cookie).toMatch(/;\s*SameSite=Lax/i)
      expect(cookie).not.toMatch(/code-verifier/i)
    }
    expect((await me(fake, cookieHeader(res))).body).toEqual({ kind: 'email', email: B })
  })

  it('[accounts 10] a wrong sign in code answers 400 wrong_code and sets no cookie', async () => {
    const fake = accountFake()
    fake.addEmailAccount(B)
    await call(fake, postJson('/api/sign-in', { email: B }))
    const right = lastMailTo(fake, B).code
    const res = await call(
      fake,
      postJson('/api/sign-in/verify', { email: B, code: right === '123456' ? '654321' : '123456' }),
    )
    expect(res.status).toBe(400)
    expect(await res.json()).toEqual({ error: 'wrong_code' })
    expect(setCookies(res)).toEqual([])
  })

  it('[accounts 11] an unknown address sends no email and makes no account', async () => {
    const fake = accountFake()
    const res = await call(fake, postJson('/api/sign-in', { email: 'nobody@example.com' }))
    expect(res.status).toBe(200)
    expect(fake.mail).toEqual([])
    expect(fake.users.size).toBe(0)
    const verify = await call(
      fake,
      postJson('/api/sign-in/verify', { email: 'nobody@example.com', code: '123456' }),
    )
    expect(verify.status).toBe(400)
    expect(fake.users.size).toBe(0)
  })

  it('[accounts 13] a guest on this device is deleted after the sign in, and the device becomes the account', async () => {
    const fake = accountFake()
    fake.addEmailAccount(B)
    const cookie = await newGuest(fake)
    const guestId = guestIdOf(fake)
    const after = await signedInDevice(fake, B, cookie)
    expect(fake.users.has(guestId)).toBe(false)
    expect((await me(fake, after)).body).toEqual({ kind: 'email', email: B })
  })

  it('[accounts 12] two devices share one account: the second sees the same account', async () => {
    const fake = accountFake()
    const first = await newGuest(fake)
    const guestId = guestIdOf(fake)
    await call(fake, postJson('/api/account/email', { email: A }, first))
    const added = await call(
      fake,
      postJson('/api/account/email/verify', { email: A, code: lastMailTo(fake, A).code }, first),
    )
    const deviceA = cookieHeader(added, first)
    const deviceB = await signedInDevice(fake, A)
    fake.data.set(guestId, { sessions: [{ id: 's1' }] })
    const exportOf = async (cookie: string) =>
      (await (await call(fake, get('/api/account/export', cookie))).json<{ tables: unknown }>()).tables
    expect(await exportOf(deviceB)).toEqual(await exportOf(deviceA))
  })
})

describe('signing out', () => {
  it('[accounts 14] an email account signs out this device only (scope local), and the cookies are cleared', async () => {
    const fake = accountFake()
    fake.addEmailAccount(B)
    const one = await signedInDevice(fake, B)
    const two = await signedInDevice(fake, B)
    const res = await call(fake, post('/api/sign-out', { cookie: one }))
    expect(res.status).toBe(200)
    expect(fake.events).toContain('logout:local')
    expect(cookieHeader(res, one)).toBe('')
    expect((await me(fake, one)).status).toBe(401)
    expect((await me(fake, two)).body).toEqual({ kind: 'email', email: B })
  })

  it('[accounts 14] a guest cannot sign out: 409, nothing is ended', async () => {
    const fake = accountFake()
    const cookie = await newGuest(fake)
    const res = await call(fake, post('/api/sign-out', { cookie }))
    expect(res.status).toBe(409)
    expect(await res.json()).toEqual({ error: 'guest_cannot_sign_out' })
    expect(fake.events).not.toContain('logout:local')
    expect((await me(fake, cookie)).body).toEqual({ kind: 'guest' })
  })
})

describe('download my data', () => {
  it('[accounts 18] one JSON file, named by date, never cached, with every part and no token', async () => {
    vi.useFakeTimers({ toFake: ['Date'], now: new Date('2026-10-22T09:30:00Z') })
    const fake = accountFake()
    const cookie = await newGuest(fake)
    const guestId = guestIdOf(fake)
    const tables = Object.fromEntries(
      USER_TABLE_NAMES.map((name) => [name, [{ user_id: guestId, table: name }]]),
    )
    fake.data.set(guestId, tables)
    const store: FileStore = {
      name: 'stand-in',
      exportFor: (who) =>
        Promise.resolve([{ file: `files of ${who.userId === guestId ? 'the guest' : 'someone'}` }]),
      deleteAllFor: () => Promise.resolve(),
    }
    const res = await call(fake, get('/api/account/export', cookie), { fileStores: [store] })
    expect(res.status).toBe(200)
    expect(res.headers.get('content-type')).toMatch(/^application\/json/)
    expect(res.headers.get('content-disposition')).toBe(
      'attachment; filename="puhuscribe-data-2026-10-22.json"',
    )
    expect(res.headers.get('cache-control')).toBe('no-store')
    expect(res.headers.get('access-control-allow-origin')).toBeNull()
    const text = await res.text()
    const file = JSON.parse(text) as Record<string, unknown>
    expect(Object.keys(file)).toEqual(['about', 'exported_at', 'account', 'tables', 'files'])
    expect(file.exported_at).toBe('2026-10-22T09:30:00.000Z')
    expect(file.account).toMatchObject({ id: guestId, email: null, is_anonymous: true })
    expect(Object.keys(file.account as object).sort()).toEqual(
      ['created_at', 'email', 'email_confirmed_at', 'id', 'is_anonymous', 'last_sign_in_at'].sort(),
    )
    expect(file.tables).toEqual(tables)
    expect(file.files).toEqual({ 'stand-in': [{ file: 'files of the guest' }] })
    for (const token of fake.issued.filter((value) => value !== guestId)) expect(text).not.toContain(token)
  })

  it('[accounts 18] works for an email account too, and refuses without a sign in', async () => {
    const fake = accountFake()
    fake.addEmailAccount(B)
    const cookie = await signedInDevice(fake, B)
    const res = await call(fake, get('/api/account/export', cookie))
    expect(res.status).toBe(200)
    expect((await res.json<{ account: { email: string } }>()).account.email).toBe(B)
    expect((await call(fake, get('/api/account/export'))).status).toBe(401)
    expect((await call(fake, post('/api/account/export', { cookie }))).status).toBe(405)
  })

  it('[accounts 18] the "about" part describes every user table of the inventory', async () => {
    const fake = accountFake()
    const cookie = await newGuest(fake)
    const file = await (
      await call(fake, get('/api/account/export', cookie))
    ).json<{
      about: { tables: Record<string, string> }
    }>()
    expect(Object.keys(file.about.tables)).toEqual(USER_TABLE_NAMES)
  })
})

describe('delete my account', () => {
  it('[accounts 20] [accounts 23] file stores are emptied first, then the database row; the cookies are cleared', async () => {
    const fake = accountFake()
    const cookie = await newGuest(fake)
    const guestId = guestIdOf(fake)
    const store: FileStore = {
      name: 'stand-in',
      exportFor: () => Promise.resolve([]),
      deleteAllFor: (who) => {
        fake.events.push(`files:${who.userId === guestId ? 'own' : 'other'}`)
        return Promise.resolve()
      },
    }
    fake.events.length = 0
    const res = await call(fake, post('/api/account/delete', { cookie }), { fileStores: [store] })
    expect(res.status).toBe(200)
    expect(await res.json()).toEqual({ deleted: true })
    expect(fake.events.filter((e) => e !== 'rpc:my_account')).toEqual(['files:own', 'rpc:delete_my_account'])
    expect(fake.users.has(guestId)).toBe(false)
    expect(cookieHeader(res, cookie)).toBe('')
  })

  it('[accounts 23] when a file store fails, nothing in the database is deleted and the answer says not deleted', async () => {
    const fake = accountFake()
    const cookie = await newGuest(fake)
    const guestId = guestIdOf(fake)
    const calls: string[] = []
    const ok: FileStore = {
      name: 'first',
      exportFor: () => Promise.resolve([]),
      deleteAllFor: () => {
        calls.push('first')
        return Promise.resolve()
      },
    }
    const failing: FileStore = {
      name: 'second',
      exportFor: () => Promise.resolve([]),
      deleteAllFor: () => {
        calls.push('second')
        return Promise.reject(new Error('store down'))
      },
    }
    const res = await call(fake, post('/api/account/delete', { cookie }), { fileStores: [ok, failing] })
    expect(res.status).toBe(503)
    expect(await res.json()).toEqual({ error: 'not_deleted' })
    expect(calls).toEqual(['first', 'second'])
    expect(fake.events).not.toContain('rpc:delete_my_account')
    expect(fake.users.has(guestId)).toBe(true)
    expect(setCookies(res)).toEqual([])
  })

  it('[accounts 21] a signed out token cannot delete: 401, the account stays', async () => {
    const fake = accountFake()
    fake.addEmailAccount(B)
    const cookie = await signedInDevice(fake, B)
    fake.sessions.clear()
    const res = await call(fake, post('/api/account/delete', { cookie }))
    expect(res.status).toBe(401)
    expect(fake.users.size).toBe(1)
  })

  it('[accounts 22] after one device deletes the account, the other device is told it is signed out (email message) on every route', async () => {
    const fake = accountFake()
    fake.addEmailAccount(B)
    const one = await signedInDevice(fake, B)
    const two = await signedInDevice(fake, B)
    expect((await call(fake, post('/api/account/delete', { cookie: one }))).status).toBe(200)

    const today = await call(fake, get('/api/today', two))
    expect(await today.json()).toEqual({ signedIn: false, ended: true, account: 'email' })
    expect(cookieHeader(today, two)).toBe('')

    const session = await call(fake, post('/api/sessions/today', { cookie: two }))
    expect(session.status).toBe(401)
    expect(await session.json()).toEqual({ error: 'session_ended', account: 'email' })
    expect(cookieHeader(session, two)).toBe('')

    const meAnswer = await me(fake, two)
    expect(meAnswer.status).toBe(401)
    expect(meAnswer.body).toEqual({ error: 'session_ended', account: 'email' })
  })

  it("[accounts 22] a deleted guest keeps job 8's answer, with no email hint", async () => {
    const fake = accountFake()
    const cookie = await newGuest(fake)
    fake.users.clear()
    const today = await call(fake, get('/api/today', cookie))
    expect(await today.json()).toEqual({ signedIn: false, ended: true })
    const session = await call(fake, post('/api/sessions/today', { cookie }))
    expect(await session.json()).toEqual({ error: 'session_ended' })
  })

  it('[accounts 22] a new session refused because the user is gone (a foreign key to auth.users) means the account is gone', async () => {
    const supabase = fakeSupabase()
    supabase.rest = () =>
      new Response(
        JSON.stringify({
          code: '23503',
          message:
            'insert or update on table "sessions" violates foreign key constraint "sessions_user_id_fkey"',
          details: 'Key (user_id) is not present in table "users".',
        }),
        { status: 409, headers: { 'content-type': 'application/json' } },
      )
    const context = learnerContext(
      get('/api/today'),
      { url: ENV.SUPABASE_URL ?? '', key: ENV.SUPABASE_PUBLISHABLE_KEY ?? '' },
      supabase.fetch,
    )
    await expect(supabaseLearnerDb(context.client).startSession(1)).rejects.toBeInstanceOf(AccountGone)
  })
})

describe('job 8 protections cover every new route', () => {
  const writes = [
    ['/api/account/email', { email: A }],
    ['/api/account/email/verify', { email: A, code: '123456' }],
    ['/api/sign-in', { email: A }],
    ['/api/sign-in/verify', { email: A, code: '123456' }],
    ['/api/sign-out', {}],
    ['/api/account/delete', {}],
  ] as const

  it('[accounts 26] every route that changes something refuses GET, another site and a form post, and asks Supabase nothing', async () => {
    const fake = accountFake()
    const cookie = await newGuest(fake)
    fake.requests.length = 0
    for (const [path, body] of writes) {
      const viaGet = await call(fake, get(path, cookie))
      expect(viaGet.status, path).toBe(405)
      expect(viaGet.headers.get('allow')).toBe('POST')
      const evil = await call(
        fake,
        post(path, { cookie, origin: 'https://evil.example', body: JSON.stringify(body) }),
      )
      expect(evil.status, path).toBe(403)
      const form = await call(
        fake,
        post(path, { cookie, contentType: 'application/x-www-form-urlencoded', body: 'a=1' }),
      )
      expect(form.status, path).toBe(415)
      for (const res of [viaGet, evil, form]) {
        expect(res.headers.get('access-control-allow-origin')).toBeNull()
        expect(setCookies(res)).toEqual([])
      }
    }
    expect(fake.requests).toEqual([])
    expect(fake.mail).toEqual([])
    expect(fake.users.size).toBe(1)
  })

  it('[accounts 26] the read routes accept only GET and send no CORS header', async () => {
    const fake = accountFake()
    const cookie = await newGuest(fake)
    for (const path of ['/api/me', '/api/account/export']) {
      const res = await call(fake, post(path, { cookie }))
      expect(res.status, path).toBe(405)
      const ok = await call(fake, get(path, cookie))
      expect(ok.headers.get('access-control-allow-origin')).toBeNull()
    }
  })

  it('[accounts 26] without Supabase settings the request checks still come first, then 401 or 503', async () => {
    const fake = accountFake()
    const bare = { fetch: fake.fetch }
    const evil = await handleApi(post('/api/account/delete', { origin: 'https://evil.example' }), {}, bare)
    expect(evil.status).toBe(403)
    expect((await handleApi(get('/api/account/delete'), {}, bare)).status).toBe(405)
    expect((await handleApi(get('/api/account/export'), {}, bare)).status).toBe(401)
    expect((await handleApi(postJson('/api/sign-in', { email: A }), {}, bare)).status).toBe(503)
    expect(await (await handleApi(get('/api/me'), {}, bare)).json()).toEqual({ kind: 'none' })
    expect(fake.requests).toEqual([])
  })

  it('[accounts 26] the same address in the Origin header is allowed', async () => {
    const fake = accountFake()
    const res = await call(fake, post('/api/sign-in', { origin: ORIGIN, body: JSON.stringify({ email: A }) }))
    expect(res.status).toBe(200)
  })

  it('[accounts 26] only the publishable key is ever sent to Supabase', async () => {
    const fake = accountFake()
    fake.addEmailAccount(B)
    const cookie = await newGuest(fake)
    await call(fake, postJson('/api/account/email', { email: B }, cookie))
    await call(
      fake,
      postJson('/api/account/email/verify', { email: B, code: lastMailTo(fake, B).code }, cookie),
    )
    await call(
      fake,
      get('/api/account/export', cookieHeader(await call(fake, get('/api/me', cookie)), cookie)),
    )
    expect(fake.requests.length).toBeGreaterThan(3)
    for (const request of fake.requests)
      expect(request.headers.get('apikey')).toBe(ENV.SUPABASE_PUBLISHABLE_KEY)
  })
})
