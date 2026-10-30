// Cleaning for crash reports (factory/jobs/14-analytics/spec.md, "Done when"
// 25). Used by the browser before it sends a report and again by the Worker,
// which is the one that decides: a report holds only an allow list, and
// nothing that identifies a learner. The database checks the same shapes a
// third time, in the database function that stores the report.
//
// Plain functions with no browser or Worker globals, so both sides share them.

export const MAX_MESSAGE = 300
export const MAX_FRAMES = 10
export const MAX_PATH = 200

/** One stack frame as stored: a file of our own bundle, a line, a column and a function name. */
export interface CrashFrame {
  file: string
  line: number
  column: number
  fn: string
}

/** One frame as read from a stack, before it is checked. */
export interface RawFrame {
  url: string
  line: number
  column: number
  fn: string
}

const EMAIL = /[^\s@]+@[^\s@]+\.[^\s@]+/g
const UUID = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi
const JWT_LIKE = /eyJ[A-Za-z0-9_-]{8,}(\.[A-Za-z0-9_-]*)*/g
const TOKEN_LIKE = /[A-Za-z0-9_-]{32,}/g
const DIGIT_RUN = /[0-9]{6,}/g
const URL_QUERY = /(https?:\/\/[^\s?#]*)[?#]\S*/gi
// Control characters and every other kind of whitespace become one space.
const SPACES = /[\s\u0000-\u001f\u007f]+/g // eslint-disable-line no-control-regex

/** Cuts a text to at most `max` characters (code points, as Postgres counts them). */
function cap(text: string, max: number): string {
  const chars = Array.from(text)
  return chars.length <= max ? text : chars.slice(0, max).join('')
}

/**
 * Removes from a text: query strings and fragments of web addresses, email
 * addresses, ids, token shaped strings and digit runs of 6 or more. Then
 * folds spaces and cuts it to `max` characters.
 */
export function cleanText(text: string, max = MAX_MESSAGE): string {
  const cleaned = text
    .replace(URL_QUERY, '$1')
    .replace(EMAIL, '[email]')
    .replace(UUID, '[id]')
    .replace(JWT_LIKE, '[token]')
    .replace(TOKEN_LIKE, '[token]')
    .replace(DIGIT_RUN, '[number]')
    .replace(SPACES, ' ')
    .trim()
  return cap(cleaned, max)
}

/** Replaces each given value (what the learner typed) wherever it appears in the text. */
export function withoutValues(text: string, values: readonly string[]): string {
  let out = text
  const sorted = [...new Set(values.map((v) => v.trim()).filter((v) => v.length >= 2))].sort(
    (a, b) => b.length - a.length,
  )
  for (const value of sorted) {
    out = out.replace(new RegExp(value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gi'), '[typed]')
  }
  return out
}

const NAME = /^[A-Za-z_$][A-Za-z0-9_$.]{0,79}$/

/** The error's name when it has a safe shape, otherwise "Error". */
export function cleanName(name: unknown): string {
  return typeof name === 'string' && NAME.test(name) ? name : 'Error'
}

const SEGMENT = /^[A-Za-z0-9_-]+$/
const UUID_ONE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

function isIdSegment(segment: string): boolean {
  return (
    !SEGMENT.test(segment) ||
    UUID_ONE.test(segment) ||
    /^[0-9]+$/.test(segment) ||
    /[0-9]{6,}/.test(segment) ||
    (segment.length >= 16 && /[0-9]/.test(segment)) ||
    segment.length >= 32
  )
}

/**
 * The page path with every id replaced by :id and no query or fragment, for
 * example "/api/sessions/:id/step".
 */
export function cleanPath(path: unknown): string {
  if (typeof path !== 'string') return '/'
  const bare = path.split(/[?#]/)[0] ?? ''
  if (!bare.startsWith('/')) return '/'
  const segments = bare
    .split('/')
    .filter((segment) => segment !== '')
    .map((segment) => (isIdSegment(segment) ? ':id' : segment))
  const cleaned = `/${segments.join('/')}`
  return cleaned.length <= MAX_PATH ? cleaned : '/'
}

const FN_KEEP = /[^A-Za-z0-9_$.<> -]/g

/** A function name with only safe characters, or nothing when it holds anything cleanText would remove. */
function cleanFn(fn: string): string {
  const trimmed = fn.trim()
  if (cleanText(trimmed, 1000) !== trimmed) return ''
  const kept = cap(trimmed.replace(FN_KEEP, '').trim(), 100)
  return cleanText(kept, 100) === kept ? kept : ''
}

function lineNumber(value: unknown): number | null {
  return typeof value === 'number' && Number.isInteger(value) && value >= 0 && value <= 9_999_999
    ? value
    : null
}

/**
 * Keeps up to 10 frames whose file is one of our own (ownFile gives the
 * stored file name, or null for anything else), with safe function names.
 */
export function cleanFrames(
  frames: readonly RawFrame[],
  ownFile: (url: string) => string | null,
): CrashFrame[] {
  const out: CrashFrame[] = []
  for (const frame of frames) {
    if (out.length >= MAX_FRAMES) break
    const file = ownFile(frame.url)
    const line = lineNumber(frame.line)
    const column = lineNumber(frame.column)
    if (file === null || line === null || column === null) continue
    out.push({ file, line, column, fn: cleanFn(frame.fn) })
  }
  return out
}

const CHROME_FRAME = /^\s*at (?:(.*?) \()?(.+?):(\d+):(\d+)\)?\s*$/
const GECKO_FRAME = /^\s*(.*?)@(.+?):(\d+):(\d+)\s*$/

/** Reads the frames of a stack in Chrome's ("at f (url:1:2)") or Safari's and Firefox's ("f@url:1:2") form. */
export function parseStack(stack: unknown): RawFrame[] {
  if (typeof stack !== 'string') return []
  const frames: RawFrame[] = []
  for (const line of stack.split('\n')) {
    const match = CHROME_FRAME.exec(line) ?? GECKO_FRAME.exec(line)
    if (!match) continue
    const [, fn = '', url = '', lineText = '', columnText = ''] = match
    frames.push({ url, line: Number(lineText), column: Number(columnText), fn: fn.replace(/^async /, '') })
  }
  return frames
}

/** A browser frame's file, when it is one of the app's own bundle files: "/assets/index-abc.js". */
export function ownBrowserFile(url: string, origin: string): string | null {
  try {
    const parsed = new URL(url, origin)
    if (parsed.origin !== origin) return null
    return /^\/assets\/[A-Za-z0-9_.-]{1,100}\.js$/.test(parsed.pathname) ? parsed.pathname : null
  } catch {
    return null
  }
}

/** A Worker frame's file: the bundle file's own name, never a package. */
export function ownWorkerFile(url: string): string | null {
  if (/node_modules|^node:|^internal|^cloudflare:/.test(url)) return null
  const name = url.split(/[\\/]/).pop() ?? ''
  return /^[A-Za-z0-9_.-]{1,100}\.(m?js|ts)$/.test(name) && !name.includes('..') ? name : null
}

function system(ua: string): string {
  if (/iPhone|iPad|iPod/.test(ua)) return 'iOS'
  if (ua.includes('Android')) return 'Android'
  if (ua.includes('CrOS')) return 'ChromeOS'
  if (ua.includes('Windows')) return 'Windows'
  if (/Macintosh|Mac OS X/.test(ua)) return 'macOS'
  if (ua.includes('Linux')) return 'Linux'
  return 'Other system'
}

function browser(ua: string): string {
  const rules: [RegExp, string][] = [
    [/Edg(?:A|iOS)?\/(\d+)/, 'Edge'],
    [/SamsungBrowser\/(\d+)/, 'Samsung Internet'],
    [/(?:Firefox|FxiOS)\/(\d+)/, 'Firefox'],
    [/(?:CriOS|Chrome)\/(\d+)/, 'Chrome'],
    [/Version\/(\d+)[^ ]* (?:Mobile\/\S+ )?Safari\//, 'Safari'],
  ]
  for (const [pattern, name] of rules) {
    const version = pattern.exec(ua)?.[1]
    if (version) return `${name} ${String(Number(version))}`
  }
  return 'Other browser'
}

/** A coarse browser and system label such as "Safari 17, iOS". The user agent itself is never kept. */
export function browserLabel(userAgent: string | null): string {
  if (!userAgent) return 'Unknown'
  return `${browser(userAgent)}, ${system(userAgent)}`
}
