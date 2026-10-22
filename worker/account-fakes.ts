// Test helpers for the account routes (not a test file itself). A fake
// Supabase that answers every Auth call the Worker makes for accounts (guest
// sign up, renewal, email change, sign in codes, sign out) and the three
// database functions of job 11 (my_account, export_my_data,
// delete_my_account), and records every request. It behaves as the job's
// spec and the local Supabase do: an email is added only with its code, a
// sign in code is sent only to an existing account, and a signed out or
// deleted sign in is no longer live. Nothing here is used by the app.

import type { Fetch } from './learner-auth.ts'
import type { RecordedRequest } from './test-fakes.ts'

export interface FakeUser {
  id: string
  email: string | null
  isAnonymous: boolean
  /** The address an email change waits for, and its code. */
  pending: { email: string; code: string } | null
  createdAt: string
}

export interface FakeMail {
  to: string
  code: string
  kind: 'email_change' | 'magic_link'
}

export interface AccountFake {
  fetch: Fetch
  requests: RecordedRequest[]
  users: Map<string, FakeUser>
  /** Live sign ins: session id to user id. */
  sessions: Map<string, string>
  mail: FakeMail[]
  /** Every token, user id and session id handed out, for the log check. */
  issued: string[]
  /** What export_my_data answers, per user id. */
  data: Map<string, Record<string, unknown[]>>
  /** The order of interesting calls, such as "rpc:delete_my_account". */
  events: string[]
  /** Makes Auth and the database answer 503 from now on. */
  down: boolean
  /** Adds an email account directly, as an earlier sign up would have. */
  addEmailAccount: (email: string) => FakeUser
}

function base64url(value: unknown): string {
  return btoa(JSON.stringify(value)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
}

function fromBase64url(text: string): unknown {
  return JSON.parse(atob(text.replace(/-/g, '+').replace(/_/g, '/')))
}

export function accountFake(): AccountFake {
  const access = new Map<string, { userId: string; sessionId: string }>()
  const refresh = new Map<string, { userId: string; sessionId: string }>()
  const signInCodes = new Map<string, string>()
  let counter = 0

  const answer = (status: number, body: unknown) =>
    new Response(status === 204 ? null : JSON.stringify(body), {
      status,
      headers: { 'content-type': 'application/json' },
    })

  const userJson = (user: FakeUser) => ({
    id: user.id,
    aud: 'authenticated',
    role: 'authenticated',
    email: user.email ?? '',
    new_email: user.pending?.email,
    is_anonymous: user.isAnonymous,
    app_metadata: {},
    user_metadata: {},
    created_at: user.createdAt,
  })

  const issue = (user: FakeUser, sessionId?: string) => {
    counter += 1
    const sid = sessionId ?? crypto.randomUUID()
    fake.sessions.set(sid, user.id)
    const now = Math.floor(Date.now() / 1000)
    const accessToken = `${base64url({ alg: 'HS256', typ: 'JWT' })}.${base64url({
      sub: user.id,
      session_id: sid,
      is_anonymous: user.isAnonymous,
      exp: now + 3600,
      role: 'authenticated',
      n: counter,
    })}.fake-signature-${String(counter)}`
    const refreshToken = `fake-refresh-${String(counter)}-${sid.slice(0, 8)}`
    access.set(accessToken, { userId: user.id, sessionId: sid })
    refresh.set(refreshToken, { userId: user.id, sessionId: sid })
    fake.issued.push(accessToken, refreshToken, sid, user.id)
    return {
      access_token: accessToken,
      token_type: 'bearer',
      expires_in: 3600,
      expires_at: now + 3600,
      refresh_token: refreshToken,
      user: userJson(user),
    }
  }

  /** The live sign in an Authorization header carries, or null. */
  const signedIn = (request: RecordedRequest) => {
    const token = (request.headers.get('authorization') ?? '').replace(/^Bearer /, '')
    const found = access.get(token)
    if (!found) return null
    const user = fake.users.get(found.userId)
    if (!user || fake.sessions.get(found.sessionId) !== found.userId) return null
    return { user, sessionId: found.sessionId, token }
  }

  const userByEmail = (email: string) => [...fake.users.values()].find((u) => u.email === email)
  const sixDigits = () => String(100000 + Math.floor(Math.random() * 900000))
  const deleteUser = (id: string) => {
    fake.users.delete(id)
    fake.data.delete(id)
    for (const [sid, uid] of fake.sessions) if (uid === id) fake.sessions.delete(sid)
  }

  const fake: AccountFake = {
    requests: [],
    users: new Map(),
    sessions: new Map(),
    mail: [],
    issued: [],
    data: new Map(),
    events: [],
    down: false,
    addEmailAccount: (email) => {
      const user: FakeUser = {
        id: crypto.randomUUID(),
        email,
        isAnonymous: false,
        pending: null,
        createdAt: new Date().toISOString(),
      }
      fake.users.set(user.id, user)
      fake.issued.push(user.id)
      return user
    },
    fetch: async (input, init) => {
      const request = new Request(input, init)
      const recorded: RecordedRequest = {
        method: request.method,
        url: new URL(request.url),
        headers: new Headers(request.headers),
        body: request.body ? await request.text() : '',
      }
      fake.requests.push(recorded)
      if (fake.down) return answer(503, { message: 'unavailable' })
      const path = recorded.url.pathname
      const body = (recorded.body ? JSON.parse(recorded.body) : {}) as Record<string, unknown>

      // Database functions, as PostgREST answers them.
      if (path.startsWith('/rest/v1/rpc/')) {
        const name = path.slice('/rest/v1/rpc/'.length)
        fake.events.push(`rpc:${name}`)
        const live = signedIn(recorded)
        const token = (recorded.headers.get('authorization') ?? '').replace(/^Bearer /, '')
        if (!access.has(token)) {
          return answer(401, { code: '42501', message: `permission denied for function ${name}` })
        }
        if (name === 'my_account') {
          if (!live) return answer(200, [])
          return answer(200, [
            {
              id: live.user.id,
              email: live.user.email,
              is_anonymous: live.user.isAnonymous,
              created_at: live.user.createdAt,
              last_sign_in_at: live.user.createdAt,
              email_confirmed_at: live.user.email ? live.user.createdAt : null,
            },
          ])
        }
        if (name === 'export_my_data') {
          const userId = access.get(token)?.userId ?? ''
          return answer(200, { tables: fake.data.get(userId) ?? {} })
        }
        if (name === 'delete_my_account') {
          if (!live) return answer(400, { code: '28000', message: 'there is no live sign in for this token' })
          deleteUser(live.user.id)
          return answer(204, null)
        }
        return answer(404, { message: 'not found' })
      }

      if (path === '/auth/v1/signup' && recorded.method === 'POST') {
        const user: FakeUser = {
          id: crypto.randomUUID(),
          email: null,
          isAnonymous: true,
          pending: null,
          createdAt: new Date().toISOString(),
        }
        fake.users.set(user.id, user)
        return answer(200, issue(user))
      }

      if (path === '/auth/v1/token' && recorded.url.searchParams.get('grant_type') === 'refresh_token') {
        const found = refresh.get(typeof body.refresh_token === 'string' ? body.refresh_token : '')
        if (found) refresh.delete(typeof body.refresh_token === 'string' ? body.refresh_token : '')
        const user = found ? fake.users.get(found.userId) : undefined
        if (!found || !user || fake.sessions.get(found.sessionId) !== user.id) {
          return answer(400, {
            code: 'refresh_token_not_found',
            error_code: 'refresh_token_not_found',
            msg: 'Invalid Refresh Token: Refresh Token Not Found',
          })
        }
        return answer(200, issue(user, found.sessionId))
      }

      if (path === '/auth/v1/user' && recorded.method === 'GET') {
        const live = signedIn(recorded)
        if (!live)
          return answer(403, {
            code: 'session_not_found',
            error_code: 'session_not_found',
            msg: 'Session not found',
          })
        return answer(200, userJson(live.user))
      }

      if (path === '/auth/v1/user' && recorded.method === 'PUT') {
        const live = signedIn(recorded)
        if (!live)
          return answer(403, {
            code: 'session_not_found',
            error_code: 'session_not_found',
            msg: 'Session not found',
          })
        const email = typeof body.email === 'string' ? body.email : ''
        const other = userByEmail(email)
        if (other && other.id !== live.user.id) {
          return answer(422, {
            code: 'email_exists',
            error_code: 'email_exists',
            msg: 'A user with this email address has already been registered',
          })
        }
        const code = sixDigits()
        live.user.pending = { email, code }
        fake.mail.push({ to: email, code, kind: 'email_change' })
        return answer(200, userJson(live.user))
      }

      if (path === '/auth/v1/otp' && recorded.method === 'POST') {
        const email = typeof body.email === 'string' ? body.email : ''
        const user = userByEmail(email)
        if (!user) {
          if (body.create_user === false) {
            return answer(422, {
              code: 'otp_disabled',
              error_code: 'otp_disabled',
              msg: 'Signups not allowed for otp',
            })
          }
          return answer(500, { message: 'the fake never makes accounts by email' })
        }
        const code = sixDigits()
        signInCodes.set(email, code)
        fake.mail.push({ to: email, code, kind: 'magic_link' })
        return answer(200, {})
      }

      if (path === '/auth/v1/verify' && recorded.method === 'POST') {
        const email = typeof body.email === 'string' ? body.email : ''
        const token = typeof body.token === 'string' ? body.token : ''
        const expired = () =>
          answer(403, {
            code: 'otp_expired',
            error_code: 'otp_expired',
            msg: 'Token has expired or is invalid',
          })
        if (body.type === 'email_change') {
          const user = [...fake.users.values()].find(
            (u) => u.pending?.email === email && u.pending.code === token,
          )
          if (!user) return expired()
          user.email = email
          user.isAnonymous = false
          user.pending = null
          return answer(200, issue(user))
        }
        if (body.type === 'email') {
          if (!token || signInCodes.get(email) !== token) return expired()
          signInCodes.delete(email)
          const user = userByEmail(email)
          if (!user) return expired()
          return answer(200, issue(user))
        }
        return expired()
      }

      if (path === '/auth/v1/logout' && recorded.method === 'POST') {
        const live = signedIn(recorded)
        fake.events.push(`logout:${recorded.url.searchParams.get('scope') ?? 'global'}`)
        if (live) fake.sessions.delete(live.sessionId)
        return answer(204, null)
      }

      return answer(404, { message: 'not found' })
    },
  }
  return fake
}

/** The claims of an access token (for tests that check is_anonymous). */
export function claimsOf(accessToken: string): Record<string, unknown> {
  return fromBase64url(accessToken.split('.')[1] ?? '') as Record<string, unknown>
}
