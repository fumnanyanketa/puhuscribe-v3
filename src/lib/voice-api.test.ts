import { afterEach, describe, expect, it, vi } from 'vitest'
import { parseSayAnswer, parseVoiceAnswer, sayLine } from './voice-api.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.

const VOICE = { available: true, region: 'Ireland', processing: 'granted', retention: false, recordings: [] }

describe('the voice answer', () => {
  it('[speak 4] reads both choices, the region and the kept recordings', () => {
    const rec = { id: 'a', line: 'Moi!', slot: 'first', createdAt: '2026-10-26T10:00:00Z' }
    expect(parseVoiceAnswer({ ...VOICE, recordings: [rec] })).toEqual({ ...VOICE, recordings: [rec] })
  })

  it('[speak 4] refuses an answer it does not expect', () => {
    expect(parseVoiceAnswer({ ...VOICE, processing: 'yes' })).toBeNull()
    expect(parseVoiceAnswer({ ...VOICE, recordings: [{ id: 'a', slot: 'third' }] })).toBeNull()
    expect(parseVoiceAnswer(null)).toBeNull()
  })
})

describe('the say answer', () => {
  it('[speak 7] [speak 15] reads the class and hint, nothing else', () => {
    expect(parseSayAnswer({ feedbackClass: 'clear' })).toEqual({ feedbackClass: 'clear' })
    expect(parseSayAnswer({ feedbackClass: 'close', hint: { kind: 'double', letter: 'k' } })).toEqual({
      feedbackClass: 'close',
      hint: { kind: 'double', letter: 'k' },
    })
    // A transcript in the answer is never carried into the app.
    expect(parseSayAnswer({ feedbackClass: 'clear', transcript: 'moi' })).toEqual({ feedbackClass: 'clear' })
  })

  it('[speak 7] a close answer without a usable hint is not shown', () => {
    expect(parseSayAnswer({ feedbackClass: 'close' })).toBeNull()
    expect(parseSayAnswer({ feedbackClass: 'close', hint: { kind: 'vowel', want: 'ä' } })).toBeNull()
    expect(parseSayAnswer({ feedbackClass: 'great' })).toBeNull()
  })
})

describe('sending a recording', () => {
  afterEach(() => {
    vi.unstubAllGlobals()
  })

  function answering(status: number, body: unknown) {
    const fetch = vi.fn(() => Promise.resolve(new Response(JSON.stringify(body), { status })))
    vi.stubGlobal('fetch', fetch)
    return fetch
  }

  it('[speak 14] sends the session, the line and the WAV as base64 JSON, and no reference text', async () => {
    const fetch = answering(200, { feedbackClass: 'clear' })
    await sayLine('s', 3, new Uint8Array([82, 73, 70, 70]))
    const [path, init] = fetch.mock.calls[0] as unknown as [string, RequestInit]
    expect(path).toBe('/api/speech/say')
    expect(init.method).toBe('POST')
    expect(JSON.parse(init.body as string)).toEqual({ sessionId: 's', lineId: 3, audio: 'UklGRg==' })
  })

  it('[speak 13] [speak 14] maps each refusal to what the screen shows', async () => {
    answering(403, { error: 'no_voice_consent' })
    expect((await sayLine('s', 1, new Uint8Array(4))).kind).toBe('no_consent')
    answering(429, { error: 'too_many' })
    expect((await sayLine('s', 1, new Uint8Array(4))).kind).toBe('too_many')
    answering(503, { error: 'speech_not_available' })
    expect((await sayLine('s', 1, new Uint8Array(4))).kind).toBe('not_available')
    answering(503, { error: 'speech_busy' })
    expect((await sayLine('s', 1, new Uint8Array(4))).kind).toBe('failed')
    answering(401, {})
    expect((await sayLine('s', 1, new Uint8Array(4))).kind).toBe('signed_out')
  })
})
