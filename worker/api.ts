// Every /api/* route of the app. The shared rules (same origin, JSON, never
// cached, POST with JSON for every change) are in worker/http.ts.
// Keys stay in the Worker's environment and are never written into a response.
// This code writes nothing to the log. When a sign in is lost, the Supabase
// library (auth-js) may write one short error line with no personal data; no
// cookie, token, user id, address or header is ever logged
// (factory/jobs/8-first-session/spec.md, "Done when" 19; worker/logs.test.ts).

import {
  RECORDABLE_STEPS,
  type FrontDoorAnswer,
  type RecordableStep,
  type ReviewSession,
} from '../src/lib/session-types.ts'
import { json, readBody, refuseNonGet, refuseUnsafeWrite, withCookies } from './http.ts'
import {
  hasAuthCookie,
  learnerContext,
  signInState,
  supabaseSettings,
  type Fetch,
  type LearnerContext,
  type SupabaseEnv,
} from './learner-auth.ts'
import type { SpeechEnv } from './providers/speech-feedback.ts'
import { DatabaseUnavailable, supabaseLearnerDb, type LearnerDb, type ReviewDb } from './learner-db.ts'
import {
  answer as answerReview,
  finishKeep,
  itemsFor,
  openReviewSession,
  parseAnswer,
  reviewItems,
} from './review.ts'
import { ContentUnusable, frontDoorState, readySession, todayFor } from './session-plan.ts'
import {
  deleteRecordings,
  playRecording,
  recall,
  say,
  voiceConsent,
  voiceState,
  type RouteKit,
  type SpeechDeps,
} from './speech.ts'

export type ApiEnv = SupabaseEnv & SpeechEnv

export interface ApiDeps extends SpeechDeps {
  fetch: Fetch
  /** Tests pass a fake database; normally it is Supabase, as the learner. */
  learnerDb?: (context: LearnerContext) => LearnerDb
}

const defaultDeps: ApiDeps = { fetch: (input, init) => fetch(input, init) }

const DATABASE_TIMEOUT_MS = 3000

type DatabaseStatus = 'reachable' | 'unreachable' | 'not_configured'

// One real query through the Supabase project. POST /graphql/v1 runs the
// SQL function graphql_public.graphql inside Postgres, so a JSON answer means
// the database itself replied. It needs no table, and the publishable key may
// call it (the REST root needs a secret key). PostgREST answers 503 when it
// cannot reach Postgres.
async function checkDatabase(env: ApiEnv, deps: ApiDeps): Promise<DatabaseStatus> {
  const settings = supabaseSettings(env)
  if (!settings) return 'not_configured'
  try {
    const res = await deps.fetch(`${settings.url}/graphql/v1`, {
      method: 'POST',
      headers: { apikey: settings.key, 'content-type': 'application/json' },
      body: JSON.stringify({ query: '{ __typename }' }),
      signal: AbortSignal.timeout(DATABASE_TIMEOUT_MS),
    })
    if (!res.ok) return 'unreachable'
    if (!(res.headers.get('content-type') ?? '').includes('application/json')) return 'unreachable'
    await res.json()
    return 'reachable'
  } catch {
    return 'unreachable'
  }
}

async function health(request: Request, env: ApiEnv, deps: ApiDeps): Promise<Response> {
  if (request.method === 'HEAD') {
    return new Response(null, { status: 200, headers: json(null).headers })
  }
  if (request.method !== 'GET') {
    await readBody(request)
    return json({ error: 'method_not_allowed' }, 405, { allow: 'GET, HEAD' })
  }
  return json({ status: 'ok', service: 'puhuscribe', database: await checkDatabase(env, deps) })
}

const NOT_CONFIGURED = (): Response => json({ error: 'not_available' }, 503)

function databaseFor(context: LearnerContext, deps: ApiDeps): LearnerDb {
  return deps.learnerDb ? deps.learnerDb(context) : supabaseLearnerDb(context.client)
}

function isReviewDb(db: LearnerDb | (LearnerDb & ReviewDb)): db is LearnerDb & ReviewDb {
  return 'reviewQueue' in db
}

// The Keep it step's database (job 9-daily-review): the same Supabase client,
// as the learner. Unit tests pass one fake for both (worker/test-fakes.ts); a
// job 8 test whose fake has no review calls gets the real client, which those
// tests never reach.
function reviewDatabaseFor(context: LearnerContext, db: LearnerDb): ReviewDb {
  return isReviewDb(db) ? db : supabaseLearnerDb(context.client)
}

/** Both databases of a signed in request: job 8's, then the review one. */
function databasesFor(context: LearnerContext, deps: ApiDeps): [LearnerDb, ReviewDb] {
  const db = databaseFor(context, deps)
  return [db, reviewDatabaseFor(context, db)]
}

// Turns a fault while reading or writing into an answer. This code logs nothing.
function faultAnswer(error: unknown): Response {
  if (error instanceof ContentUnusable) return json({ error: 'content_unusable' }, 500)
  if (error instanceof DatabaseUnavailable) return json({ error: 'not_available' }, 503)
  return json({ error: 'not_available' }, 503)
}

// POST /api/guest: makes a guest account (Supabase anonymous sign in) when
// the browser has no working sign in. Pressing Start again, reloading or a
// second tab finds the existing sign in and makes nothing.
async function guest(request: Request, env: ApiEnv, deps: ApiDeps): Promise<Response> {
  const { refused } = await refuseUnsafeWrite(request)
  if (refused) return refused
  const settings = supabaseSettings(env)
  if (!settings) return NOT_CONFIGURED()
  const context = learnerContext(request, settings, deps.fetch)
  const state = await signInState(context)
  if (state === 'active') return withCookies(json({ guest: 'existing' }), context.setCookies())
  if (state === 'unavailable') return withCookies(json({ error: 'not_available' }, 503), context.setCookies())
  try {
    const { data, error } = await context.client.auth.signInAnonymously()
    // Only whether it worked goes back: no token and no user id.
    if (error || !data.session) {
      return withCookies(json({ error: 'guest_not_created' }, 503), context.setCookies())
    }
  } catch {
    return withCookies(json({ error: 'guest_not_created' }, 503), context.setCookies())
  }
  return withCookies(json({ guest: 'created' }, 201), context.setCookies())
}

// GET /api/today: what the front door shows. Changes nothing (an expired
// access token may be renewed on the way, which only replaces the cookies).
async function frontDoor(request: Request, env: ApiEnv, deps: ApiDeps): Promise<Response> {
  const refused = await refuseNonGet(request)
  if (refused) return refused
  // Without a sign in cookie the answer needs no database at all.
  if (!hasAuthCookie(request)) return json({ signedIn: false, ended: false } satisfies FrontDoorAnswer)
  const settings = supabaseSettings(env)
  if (!settings) return NOT_CONFIGURED()
  const context = learnerContext(request, settings, deps.fetch)
  const state = await signInState(context)
  const answer = (body: FrontDoorAnswer) => withCookies(json(body), context.setCookies())
  if (state === 'none') return answer({ signedIn: false, ended: false })
  if (state === 'ended') return answer({ signedIn: false, ended: true })
  if (state === 'unavailable') return withCookies(json({ error: 'not_available' }, 503), context.setCookies())
  try {
    const [db, reviewDb] = databasesFor(context, deps)
    const pick = await todayFor(db)
    const today = frontDoorState(pick)
    if (pick.kind === 'dialogue') {
      // Job 9-daily-review, "Done when" 4: a new session that will end with Keep it says so.
      const review = today === 'start' && (await reviewItems(db, reviewDb)).length > 0
      return answer({
        signedIn: true,
        today,
        canDo: pick.dialogue.canDo,
        ...(review ? { review: true } : {}),
      })
    }
    if (pick.kind === 'all_done') {
      // No new dialogue: a review only session when something is reviewable,
      // otherwise the day of the next review (statements 4 and 5).
      if ((await reviewItems(db, reviewDb)).length > 0) {
        return answer({
          signedIn: true,
          today: openReviewSession(await db.mySessions()) ? 'continue' : 'review',
        })
      }
      const nextReview = await reviewDb.nextReviewDay()
      return answer({ signedIn: true, today, ...(nextReview ? { nextReview } : {}) })
    }
    return answer({ signedIn: true, today })
  } catch (error) {
    return withCookies(faultAnswer(error), context.setCookies())
  }
}

// Every session route needs a working sign in first.
async function signedIn(
  request: Request,
  env: ApiEnv,
  deps: ApiDeps,
): Promise<
  { context: LearnerContext; refused: null } | { context: LearnerContext | null; refused: Response }
> {
  if (!hasAuthCookie(request)) return { context: null, refused: json({ error: 'signed_out' }, 401) }
  const settings = supabaseSettings(env)
  if (!settings) return { context: null, refused: NOT_CONFIGURED() }
  const context = learnerContext(request, settings, deps.fetch)
  const state = await signInState(context)
  if (state === 'active') return { context, refused: null }
  const refused =
    state === 'unavailable'
      ? json({ error: 'not_available' }, 503)
      : json({ error: state === 'ended' ? 'session_ended' : 'signed_out' }, 401)
  return { context, refused: withCookies(refused, context.setCookies()) }
}

// POST /api/sessions/today: today's session, made if needed (statement 6).
async function sessionsToday(request: Request, env: ApiEnv, deps: ApiDeps): Promise<Response> {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  const { context, refused } = await signedIn(request, env, deps)
  if (refused) return refused
  try {
    const [db, reviewDb] = databasesFor(context, deps)
    const pick = await todayFor(db)
    if (pick.kind === 'all_done' && (await reviewItems(db, reviewDb)).length > 0) {
      // Job 9-daily-review, "Done when" 7: Keep it alone, in the learner's
      // unfinished review only session or a new one.
      const open = openReviewSession(await db.mySessions()) ?? (await reviewDb.startReviewSession())
      const body: ReviewSession = { state: 'review', session: { id: open.id, step: open.step } }
      return withCookies(json(body), context.setCookies())
    }
    if (pick.kind !== 'dialogue') return withCookies(json({ state: pick.kind }), context.setCookies())
    // A dialogue session is answered exactly as in job 8. Whether it ends with
    // Keep it is asked next, through GET /api/sessions/<id>/review.
    const session = pick.open ?? (await db.startSession(pick.dialogue.id))
    return withCookies(json(await readySession(db, pick.dialogue, session)), context.setCookies())
  } catch (error) {
    return withCookies(faultAnswer(error), context.setCookies())
  }
}

function parseStep(body: string): RecordableStep | null {
  try {
    const parsed: unknown = JSON.parse(body)
    if (typeof parsed !== 'object' || parsed === null) return null
    const step = (parsed as { step?: unknown }).step
    return RECORDABLE_STEPS.find((s) => s === step) ?? null
  } catch {
    return null
  }
}

// POST /api/sessions/<id>/step with {"step": "hear" | "understand"}. Steps
// move one at a time; a step already reached changes nothing.
async function recordStep(request: Request, env: ApiEnv, deps: ApiDeps, id: string): Promise<Response> {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  const step = parseStep(write.body)
  if (!step) return json({ error: 'bad_request' }, 400)
  const { context, refused } = await signedIn(request, env, deps)
  if (refused) return refused
  const done = (body: unknown, status = 200) => withCookies(json(body, status), context.setCookies())
  try {
    const db = databaseFor(context, deps)
    const session = await db.session(id)
    if (!session) return done({ error: 'not_found' }, 404)
    if (session.endedAt !== null) return done({ error: 'session_finished' }, 409)
    const reached = RECORDABLE_STEPS.indexOf(step)
    const now =
      session.step === null
        ? -1
        : (['hear', 'understand', 'say', 'keep', 'use'] as const).indexOf(session.step)
    if (now >= reached) return done({ step: session.step })
    if (now !== reached - 1) return done({ error: 'step_out_of_order' }, 409)
    if (!(await db.setStep(id, step))) return done({ error: 'not_found' }, 404)
    return done({ step })
  } catch (error) {
    return withCookies(faultAnswer(error), context.setCookies())
  }
}

// POST /api/sessions/<id>/complete: the finish screen saves everything at
// once through public.complete_session (statement 15).
async function complete(request: Request, env: ApiEnv, deps: ApiDeps, id: string): Promise<Response> {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  const { context, refused } = await signedIn(request, env, deps)
  if (refused) return refused
  const done = (body: unknown, status = 200) => withCookies(json(body, status), context.setCookies())
  try {
    const result = await databaseFor(context, deps).completeSession(id)
    if (result === 'not_found') return done({ error: 'not_found' }, 404)
    if (result === 'not_ready') return done({ error: 'step_out_of_order' }, 409)
    return done({ saved: true })
  } catch (error) {
    return withCookies(faultAnswer(error), context.setCookies())
  }
}

const RECORDING_ROUTE =
  /^\/api\/voice\/recordings\/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$/

// The Keep it routes (factory/jobs/9-daily-review/spec.md, "Done when" 6 to
// 17). Same protections as job 8's routes: a sign in, the learner's own token
// for every read and write, the user id only from the token, 404 for a session
// that is not the learner's, and POST with JSON from this site only for any
// change.

// GET /api/sessions/<id>/review: the items of the run. Changes nothing.
async function reviewItemsRoute(request: Request, env: ApiEnv, deps: ApiDeps, id: string): Promise<Response> {
  const refusedMethod = await refuseNonGet(request)
  if (refusedMethod) return refusedMethod
  const { context, refused } = await signedIn(request, env, deps)
  if (refused) return refused
  const done = (body: unknown, status = 200) => withCookies(json(body, status), context.setCookies())
  try {
    const outcome = await itemsFor(...databasesFor(context, deps), id)
    if (outcome.kind === 'not_found') return done({ error: 'not_found' }, 404)
    if (outcome.kind === 'not_ready') return done({ error: 'step_out_of_order' }, 409)
    return done(outcome.answer)
  } catch (error) {
    return withCookies(faultAnswer(error), context.setCookies())
  }
}

// POST /api/review/answer with {"sessionId", "formId", "text", "kind": "typed"}.
async function reviewAnswerRoute(request: Request, env: ApiEnv, deps: ApiDeps): Promise<Response> {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  const parsed = parseAnswer(write.body)
  if (!parsed) return json({ error: 'bad_request' }, 400)
  const { context, refused } = await signedIn(request, env, deps)
  if (refused) return refused
  const done = (body: unknown, status = 200) => withCookies(json(body, status), context.setCookies())
  try {
    const outcome = await answerReview(...databasesFor(context, deps), parsed, new Date())
    if (outcome.kind === 'not_found') return done({ error: 'not_found' }, 404)
    if (outcome.kind === 'not_ready') return done({ error: 'step_out_of_order' }, 409)
    if (outcome.kind === 'changed') return done({ error: 'card_changed' }, 409)
    return done(outcome.feedback)
  } catch (error) {
    return withCookies(faultAnswer(error), context.setCookies())
  }
}

// POST /api/sessions/<id>/review/done: Keep it is finished.
async function reviewDoneRoute(request: Request, env: ApiEnv, deps: ApiDeps, id: string): Promise<Response> {
  const write = await refuseUnsafeWrite(request)
  if (write.refused) return write.refused
  const { context, refused } = await signedIn(request, env, deps)
  if (refused) return refused
  const done = (body: unknown, status = 200) => withCookies(json(body, status), context.setCookies())
  try {
    const outcome = await finishKeep(...databasesFor(context, deps), id, new Date())
    if (outcome.kind === 'not_found') return done({ error: 'not_found' }, 404)
    if (outcome.kind === 'not_ready') return done({ error: 'step_out_of_order' }, 409)
    return done({ step: 'keep', ended: outcome.ended })
  } catch (error) {
    return withCookies(faultAnswer(error), context.setCookies())
  }
}

const SESSION_ID = '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})'
const SESSION_ROUTE = new RegExp(`^/api/sessions/${SESSION_ID}/(step|complete|review|review/done)$`)

export async function handleApi(
  request: Request,
  env: ApiEnv,
  deps: ApiDeps = defaultDeps,
): Promise<Response> {
  const { pathname } = new URL(request.url)
  if (pathname === '/api/health') return health(request, env, deps)
  if (pathname === '/api/guest') return guest(request, env, deps)
  if (pathname === '/api/today') return frontDoor(request, env, deps)
  if (pathname === '/api/sessions/today') return sessionsToday(request, env, deps)
  const match = SESSION_ROUTE.exec(pathname)
  if (match?.[1] && match[2] === 'step') return recordStep(request, env, deps, match[1])
  if (match?.[1] && match[2] === 'complete') return complete(request, env, deps, match[1])
  // Speaking feedback and voice settings (job 10-speaking-feedback).
  const kit: RouteKit = {
    signedIn: (r) => signedIn(r, env, deps),
    learnerDb: (context) => databaseFor(context, deps),
    reviewDb: (context) => reviewDatabaseFor(context, databaseFor(context, deps)),
  }
  if (pathname === '/api/voice') return voiceState(request, env, deps, kit)
  if (pathname === '/api/voice/consent') return voiceConsent(request, env, deps, kit)
  if (pathname === '/api/voice/recordings/delete') return deleteRecordings(request, env, deps, kit)
  const recording = RECORDING_ROUTE.exec(pathname)
  if (recording?.[1]) return playRecording(request, deps, kit, recording[1])
  if (pathname === '/api/speech/say') return say(request, env, deps, kit)
  if (pathname === '/api/speech/recall') return recall(request, env, deps, kit)
  if (match?.[1] && match[2] === 'review') return reviewItemsRoute(request, env, deps, match[1])
  if (match?.[1] && match[2] === 'review/done') return reviewDoneRoute(request, env, deps, match[1])
  if (pathname === '/api/review/answer') return reviewAnswerRoute(request, env, deps)
  // The body is drained here too: an answer sent with the body unread broke
  // the next request on the same connection in the local Workers runtime.
  await readBody(request)
  return json({ error: 'not_found' }, 404)
}
