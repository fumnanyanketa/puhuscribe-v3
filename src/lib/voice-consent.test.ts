import { describe, expect, it } from 'vitest'
import { VOICE_NOTICE_VERSION, voiceNotice } from './voice-consent.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.

// Every version label the consent text has had, with a fingerprint (SHA-256)
// of its text. Changing the text without a new label fails the first test:
// give the new text a new label and add its fingerprint here, keeping the old
// ones, so every stored consents row still names the text that was shown.
const FINGERPRINTS: Record<string, string> = {
  'voice-2026-10.1': 'a6b703c4485d3f1f6547fca9e273379c899d4e90ab5d83527f2afc0724cd497d',
}

async function fingerprint(): Promise<string> {
  const text = JSON.stringify(voiceNotice('{region}'))
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text))
  return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, '0')).join('')
}

describe('the voice consent text', () => {
  it('[speak 2] has a version label that changes whenever the text changes', async () => {
    expect(Object.keys(FINGERPRINTS)).toContain(VOICE_NOTICE_VERSION)
    expect(await fingerprint()).toBe(FINGERPRINTS[VOICE_NOTICE_VERSION])
  })

  it('[speak 2] the label fits the consents table (a short label, nothing else)', () => {
    expect(VOICE_NOTICE_VERSION).toMatch(/^[A-Za-z0-9._-]{1,32}$/)
  })

  it('[speak 1] says what is recorded, where it goes, that it is deleted, what is kept, and that both choices can change', () => {
    const notice = voiceNotice('Italy')
    const all = [...notice.paragraphs, notice.keepBox, notice.changeLater].join(' ')
    expect(all).toContain('records your voice only while the record button is on, for a few seconds per line')
    expect(all).toContain("through PuhuScribe's server to Microsoft's speech service in the EU, in Italy")
    expect(all).toContain('turns it into text, and PuhuScribe compares that text with the line')
    expect(all).toContain(
      'Microsoft does not keep your recording, and PuhuScribe deletes it as soon as your feedback is ready',
    )
    expect(all).toContain('keeps the text the service heard and how close it was')
    expect(all).toContain('deleted after 90 days')
    expect(notice.keepBox).toBe(
      'Keep my recordings so I can hear my progress. We keep your first and latest try of each line for 90 days. You can delete them at any time.',
    )
    expect(notice.changeLater).toBe('You can change both choices at any time in Voice settings.')
    expect(notice.turnOn).toBe('Turn on speaking feedback')
    expect(notice.notNow).toBe('Not now')
  })

  it('[speak 1] is plain English with no em dash', () => {
    const notice = voiceNotice('Ireland')
    for (const text of [notice.heading, ...notice.paragraphs, notice.keepBox, notice.changeLater]) {
      expect(text).not.toMatch(/—|--/)
      expect(text.endsWith('.') || text === notice.heading).toBe(true)
    }
  })
})
