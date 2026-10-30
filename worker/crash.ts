import {
  MAX_FRAMES,
  browserLabel,
  cleanFrames,
  cleanName,
  cleanPath,
  cleanText,
  ownBrowserFile,
  ownWorkerFile,
  parseStack,
  type RawFrame,
} from '../src/lib/crash-clean.ts'
import { appVersion } from './app-version.ts'
import { API_HEADERS, json, refuseUnsafeWrite } from './http.ts'
import type { Fetch, SupabaseEnv } from './learner-auth.ts'
import { sendCrashReport, type CleanCrashReport } from './providers/crash-reports.ts'

// Crash reports (factory/jobs/14-analytics/spec.md, "Done when" 24 and 25).
//
// POST /api/crash takes a report from the browser: JSON from this same
// address, at most 8 KB, with only source ("browser"), name, message, frames
// and path. Anything else in it is refused. The Worker cleans every field
// again (src/lib/crash-clean.ts), adds the app version and a coarse browser
// label made from the user agent, then forgets the user agent. It never reads
// or renews the sign in cookies, and sends no user id, address, cookie,
// header, typed answer or form value on. The report goes to the database
// through worker/providers/crash-reports.ts only.
//
// reportWorkerCrash does the same for an exception inside the Worker itself.
// Nothing here writes to the log.

export const MAX_CRASH_BODY_BYTES = 8 * 1024

const REPORT_KEYS = new Set(['source', 'name', 'message', 'frames', 'path'])
const FRAME_KEYS = new Set(['file', 'line', 'column', 'fn'])

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
}

function frameFrom(value: unknown): RawFrame | null {
  if (!isRecord(value) || Object.keys(value).some((key) => !FRAME_KEYS.has(key))) return null
  const { file, line, column, fn } = value
  if (typeof file !== 'string' || typeof line !== 'number' || typeof column !== 'number') return null
  if (fn !== undefined && typeof fn !== 'string') return null
  return { url: file, line, column, fn: fn ?? '' }
}

/** A browser report, checked and cleaned; null when it holds anything outside the allow list. */
export function parseBrowserReport(
  body: string,
  origin: string,
): Pick<CleanCrashReport, 'name' | 'message' | 'frames' | 'path'> | null {
  let parsed: unknown
  try {
    parsed = JSON.parse(body)
  } catch {
    return null
  }
  if (!isRecord(parsed) || Object.keys(parsed).some((key) => !REPORT_KEYS.has(key))) return null
  const { source, name, message, frames, path } = parsed
  if (source !== 'browser' || typeof name !== 'string' || typeof message !== 'string') return null
  if (typeof path !== 'string' || path.length > 2000) return null
  if (!Array.isArray(frames) || frames.length > MAX_FRAMES) return null
  const raw = frames.map(frameFrom)
  if (raw.some((frame) => frame === null)) return null
  return {
    name: cleanName(name),
    message: cleanText(message),
    frames: cleanFrames(
      raw.filter((frame): frame is RawFrame => frame !== null),
      (url) => ownBrowserFile(url, origin),
    ),
    path: cleanPath(path),
  }
}

export interface CrashDeps {
  fetch: Fetch
}

// POST /api/crash. 204 when the report was taken (stored, or dropped by the
// hourly caps), 400 for a report outside the allow list.
export async function crashRoute(request: Request, env: SupabaseEnv, deps: CrashDeps): Promise<Response> {
  const write = await refuseUnsafeWrite(request, MAX_CRASH_BODY_BYTES)
  if (write.refused) return write.refused
  const report = parseBrowserReport(write.body, new URL(request.url).origin)
  if (!report) return json({ error: 'bad_request' }, 400)
  await sendCrashReport(env, deps.fetch, {
    source: 'browser',
    ...report,
    appVersion: appVersion(),
    browser: browserLabel(request.headers.get('user-agent')),
  })
  return new Response(null, { status: 204, headers: API_HEADERS })
}

const NOT_AN_ERROR = 'A value that is not an Error was thrown.'

/** Reports an exception the Worker did not expect. Never throws. */
export async function reportWorkerCrash(
  error: unknown,
  request: Request,
  env: SupabaseEnv,
  fetchImpl: Fetch,
): Promise<boolean> {
  try {
    const known = error instanceof Error ? error : null
    return await sendCrashReport(env, fetchImpl, {
      source: 'worker',
      name: cleanName(known?.name),
      message: known ? cleanText(known.message) : NOT_AN_ERROR,
      frames: cleanFrames(parseStack(known?.stack), ownWorkerFile),
      path: cleanPath(new URL(request.url).pathname),
      appVersion: appVersion(),
      browser: browserLabel(request.headers.get('user-agent')),
    })
  } catch {
    return false
  }
}
