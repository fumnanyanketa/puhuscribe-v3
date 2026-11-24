import { isReviewToken, parseReviewAnswer, type ReviewAnswerInput } from '../src/lib/review-link.ts'
import { json, readBody, refuseNonGet, refuseUnsafeWrite } from './http.ts'
import { supabaseSettings, type Fetch, type SupabaseEnv } from './learner-auth.ts'
import { audioPath } from './session-plan.ts'

// The reviewer's side of the private review links (fast route review-links,
// factory/jobs/review-links/spec.md, "Done when" 2, 3, 4, 7 and 9). Anyone
// with the link may use it: no account, no sign in, and no cookie is read or
// set. The secret is the last part of the address:
//
//   GET  /api/review/<secret>                         the batch's dialogues and progress
//   GET  /api/review/<secret>/dialogues/<id>          one dialogue of the batch, line by line
//   POST /api/review/<secret>/answers                 {lineId, answer, note}: saves one answer
//
// The Worker holds only the publishable key, so it asks the database as anon,
// through three functions (supabase/migrations/*_review_links.sql) that hash
// the secret and look the hash up. A wrong, deleted or malformed secret, and a
// dialogue outside the batch, all get the same 404 link_not_found, so the
// answer never shows whether a reviewer exists. A malformed secret never
// reaches the database.
//
// An answer is checked here (one of the three answers, a note of at most 500
// characters, only with "Needs a fix") and again by the database, which also
// checks the line belongs to the batch and allows at most 60 answers a minute
// per link (429 limit). Every answer is private: no-store, noindex and no
// Referer. This file writes nothing to the log.

export const MAX_REVIEW_ANSWER_BODY_BYTES = 4 * 1024
const DATABASE_TIMEOUT_MS = 5000

/** The headers of every review answer: never cached, never indexed, never sent on as a Referer. */
export const REVIEW_HEADERS: Record<string, string> = {
  'cache-control': 'no-store',
  'x-robots-tag': 'noindex, nofollow',
  'referrer-policy': 'no-referrer',
}

export type AnswerResult = 'saved' | 'no_link' | 'not_in_batch' | 'limit'

export interface ReviewLinkDb {
  /** The batch and its dialogues, or null for no such link. Throws when the database cannot answer. */
  overview(token: string): Promise<unknown>
  /** One dialogue of the batch, or null for no such link or a dialogue outside it. */
  dialogue(token: string, dialogueId: number): Promise<unknown>
  answer(token: string, input: ReviewAnswerInput): Promise<AnswerResult>
}

export class ReviewLinkUnavailable extends Error {}

/** The database, as anon with the publishable key and no sign in. */
export function supabaseReviewLinkDb(env: SupabaseEnv, fetchImpl: Fetch): ReviewLinkDb {
  async function rpc(name: string, args: Record<string, unknown>): Promise<unknown> {
    const settings = supabaseSettings(env)
    if (!settings) throw new ReviewLinkUnavailable()
    const controller = new AbortController()
    const timer = setTimeout(() => {
      controller.abort()
    }, DATABASE_TIMEOUT_MS)
    try {
      const res = await fetchImpl(`${settings.url}/rest/v1/rpc/${name}`, {
        method: 'POST',
        headers: { apikey: settings.key, 'content-type': 'application/json' },
        body: JSON.stringify(args),
        signal: controller.signal,
      })
      const answer: unknown = await res.json().catch(() => undefined)
      if (!res.ok || answer === undefined) throw new ReviewLinkUnavailable()
      return answer
    } catch {
      throw new ReviewLinkUnavailable()
    } finally {
      clearTimeout(timer)
    }
  }
  return {
    overview: (token) => rpc('review_link_overview', { p_token: token }),
    dialogue: (token, dialogueId) =>
      rpc('review_link_dialogue', { p_token: token, p_dialogue_id: dialogueId }),
    async answer(token, input) {
      const result = await rpc('review_link_answer', {
        p_token: token,
        p_line_id: input.lineId,
        p_answer: input.answer,
        p_note: input.note,
      })
      if (result === 'saved' || result === 'no_link' || result === 'not_in_batch' || result === 'limit')
        return result
      throw new ReviewLinkUnavailable()
    },
  }
}

/** The review answer with the private headers added. */
function privately(response: Response): Response {
  for (const [name, value] of Object.entries(REVIEW_HEADERS)) response.headers.set(name, value)
  return response
}

const notFound = () => privately(json({ error: 'link_not_found' }, 404))
const unavailable = () => privately(json({ error: 'not_available' }, 503))

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null
}

/**
 * The dialogue as the page gets it: each line's two audio keys become the
 * same /audio/ paths the app plays (worker/session-plan.ts). A line whose key
 * could leave the /audio/ folder gets no audio.
 */
export function withAudioPaths(dialogue: unknown): unknown {
  if (!isRecord(dialogue) || !Array.isArray(dialogue.lines)) return dialogue
  return {
    ...dialogue,
    lines: dialogue.lines.map((line: unknown) => {
      if (!isRecord(line)) return line
      const { spoken_audio: spoken, written_audio: written, ...rest } = line
      return {
        ...rest,
        spokenAudio: typeof spoken === 'string' ? audioPath(spoken) : null,
        writtenAudio: typeof written === 'string' ? audioPath(written) : null,
      }
    }),
  }
}

const ROUTE = /^\/api\/review\/([^/]+)(?:\/(answers|dialogues\/([^/]+)))?$/
const DIALOGUE_ID = /^[1-9][0-9]{0,15}$/

/** True for an address this file answers: /api/review/<anything but "answer">... */
export function isReviewLinkRoute(pathname: string): boolean {
  // /api/review/answer is the learner's daily review (job 9-daily-review), not a link.
  return pathname.startsWith('/api/review/') && pathname !== '/api/review/answer'
}

export interface ReviewLinkKit {
  db: ReviewLinkDb
}

export async function reviewLinkRoute(request: Request, kit: ReviewLinkKit): Promise<Response> {
  const { pathname } = new URL(request.url)
  const match = ROUTE.exec(pathname)
  const token = match?.[1]
  if (!match || !isReviewToken(token)) {
    await readBody(request)
    return notFound()
  }

  if (match[2] === 'answers') {
    const write = await refuseUnsafeWrite(request, MAX_REVIEW_ANSWER_BODY_BYTES)
    if (write.refused) return privately(write.refused)
    let body: unknown
    try {
      body = JSON.parse(write.body)
    } catch {
      body = null
    }
    const input = parseReviewAnswer(body)
    if ('bad' in input) return privately(json({ error: 'bad_input', field: input.bad }, 400))
    let result: AnswerResult
    try {
      result = await kit.db.answer(token, input)
    } catch {
      return unavailable()
    }
    if (result === 'no_link' || result === 'not_in_batch') return notFound()
    if (result === 'limit') return privately(json({ error: 'limit' }, 429))
    return privately(json({ saved: true }))
  }

  const refused = await refuseNonGet(request)
  if (refused) return privately(refused)
  try {
    if (match[3] !== undefined) {
      if (!DIALOGUE_ID.test(match[3])) return notFound()
      const dialogue = await kit.db.dialogue(token, Number(match[3]))
      return dialogue === null ? notFound() : privately(json(withAudioPaths(dialogue)))
    }
    const overview = await kit.db.overview(token)
    return overview === null ? notFound() : privately(json(overview))
  } catch {
    return unavailable()
  }
}

/** A new link secret: 32 random bytes (256 bits) from the Workers runtime, as base64url (43 characters). */
export function newReviewToken(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32))
  let binary = ''
  for (const byte of bytes) binary += String.fromCharCode(byte)
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
}
