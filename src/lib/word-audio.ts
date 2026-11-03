// A word's own clip (job word-audio). Every distinct word text of the road has
// one clip, read by one voice, stored at /audio/words/<key>.mp3, where the key
// is the SHA-256 of the voice name, a new line and the text: the same
// request_hash as scripts/generate/providers/voice.py, computed by
// scripts/generate/road_words.py. A clip is there only after the owner approved
// it (publish-words). When it is not there, the word card plays the whole line,
// as before, so asking for a clip that does not exist is the normal case until
// a part is approved.

/** The one voice that reads every word clip (road_words.WORD_VOICE). */
export const WORD_VOICE = 'fi-FI-SelmaNeural'

/** The clip key of a text: 64 hex characters, or null where the browser cannot hash. */
export async function wordKey(text: string, voice: string = WORD_VOICE): Promise<string | null> {
  // Older browsers and pages on plain http have no crypto.subtle: the line plays.
  const subtle = (globalThis as { crypto?: Partial<Crypto> }).crypto?.subtle
  if (!subtle || !text) return null
  try {
    const digest = await subtle.digest('SHA-256', new TextEncoder().encode(`${voice}\n${text}`))
    return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, '0')).join('')
  } catch {
    return null
  }
}

/** The clip's address for a key. */
export function wordClipPath(key: string): string {
  return `/audio/words/${key}.mp3`
}

// One answer per text for the page's life: a card opened twice asks once. A
// failed request (no network) is not kept, so a later card can ask again.
const known = new Map<string, Promise<string | null>>()

async function look(text: string): Promise<string | null> {
  const key = await wordKey(text)
  if (!key) return null
  const path = wordClipPath(key)
  let answer: Response
  try {
    answer = await fetch(path, { method: 'HEAD', credentials: 'same-origin' })
  } catch {
    known.delete(text)
    return null
  }
  // A missing file can come back as the app's own page (status 200, HTML), so
  // only an audio answer counts as the clip.
  const type = answer.headers.get('content-type') ?? ''
  return answer.ok && type.startsWith('audio/') ? path : null
}

/**
 * The address of the word's own approved clip, or null when it has none (or it
 * cannot be found out), in which case the card plays the whole line.
 */
export function wordClip(text: string): Promise<string | null> {
  let found = known.get(text)
  if (!found) {
    found = look(text)
    known.set(text, found)
  }
  return found
}
