import { describe, expect, it } from 'vitest'
import { VOICE_NOTICE_VERSION, voiceNotice } from '../lib/voice-consent.ts'
import { DELETE_TEXT } from './DeletePage.tsx'
import { CODE_WORKS, GUEST_WARNING, SENDS_CODE, SIGN_IN_SENT, TAKEN_WARNING } from './EmailFlow.tsx'
import { FEEDBACK_INTRO } from './FeedbackPage.tsx'
import { GUEST_LINE } from './road-copy.ts'
import * as note from './save-note-copy.ts'

// Statement 43 of factory/jobs/19-redesign/spec.md: the words that warn a
// learner or ask for consent stay word for word, even where a drawing shows a
// shorter line. They may only get smaller and quieter. These are the texts as
// they stood on 1 November 2026, copied here on purpose, so that changing a
// word in the app turns this test red. Changing any of them needs the owner's
// approval, and the version label of the voice text (src/lib/voice-consent.ts).
//
// The save note's words are the owner's own change of 1 November 2026 ("Create
// an account to save your progress.", button "Create account", centred); that
// change is listed in build.md.

describe('protected copy', () => {
  it('[redesign 43] the guest line, with the adult line, is word for word', () => {
    expect(GUEST_LINE).toBe(
      'Starting creates a guest account on this device so your progress is saved. PuhuScribe is for adults, 18 and over.',
    )
  })

  it('[redesign 43] [redesign 35] the sentences on the email screens are word for word', () => {
    expect(SENDS_CODE).toBe(
      'We send a 6 digit code to this address. We use your email only to send you sign in codes.',
    )
    expect(TAKEN_WARNING).toBe(
      'If this email already has a PuhuScribe account, the code signs you in to that account instead. Your guest progress on this device is then deleted, because progress cannot be moved between accounts.',
    )
    expect(GUEST_WARNING).toBe(
      'This device has a guest account. Signing in deletes its progress, because progress cannot be moved between accounts. To keep it, add your email to the guest account instead.',
    )
    expect(SIGN_IN_SENT).toBe('If this email has a PuhuScribe account, we sent it a 6 digit code.')
    expect(CODE_WORKS).toBe('The code works for one hour.')
  })

  it('[redesign 43] [redesign 38] the delete warning is word for word', () => {
    expect(DELETE_TEXT).toBe(
      'This deletes your account and everything saved with it, including your progress and any recordings. It cannot be undone. Download your data first if you want a copy.',
    )
  })

  it('[redesign 43] [redesign 40] the feedback line is word for word', () => {
    expect(FEEDBACK_INTRO).toBe(
      'Tell us what worked, what did not, or what broke. Please do not include personal details.',
    )
  })

  it('[redesign 43] [redesign 29] the whole speaking consent text is word for word, with its version label', () => {
    const where = (region: string) =>
      `The recording goes from this phone through PuhuScribe's server to Microsoft's speech service ${region}. The service turns it into text, and PuhuScribe compares that text with the line.`
    const common = {
      heading: 'Speaking feedback',
      keepBox:
        'Keep my recordings so I can hear my progress. We keep your first and latest try of each line for 90 days. You can delete them at any time.',
      changeLater: 'You can change both choices at any time in Voice settings.',
      turnOn: 'Turn on speaking feedback',
      notNow: 'Not now',
    }
    const paragraphs = (region: string) => [
      'To give you feedback, PuhuScribe records your voice only while the record button is on, for a few seconds per line.',
      where(region),
      'Microsoft does not keep your recording, and PuhuScribe deletes it as soon as your feedback is ready.',
      'PuhuScribe keeps the text the service heard and how close it was, to check that the feedback works. That text is deleted after 90 days.',
      // Job 16-tutor-step (owner's call 3 of 3 November 2026, spoken answers to Otso) added this
      // paragraph and moved the label from voice-2026-10.1 to voice-2026-11.1.
      'When you speak an answer to Otso, the AI tutor, the service turns your recording into text in the same way. That text goes to Anthropic in the United States so Otso can answer, and PuhuScribe keeps neither the recording nor the text.',
    ]
    expect(VOICE_NOTICE_VERSION).toBe('voice-2026-11.1')
    expect(voiceNotice('Italy')).toEqual({ ...common, paragraphs: paragraphs('in the EU, in Italy') })
    expect(voiceNotice(null)).toEqual({ ...common, paragraphs: paragraphs('in the EU') })
  })

  it('[redesign 43] the save note carries the owner words of 1 November 2026', () => {
    expect(note.SAVE_NOTE_SENTENCE).toBe('Create an account to save your progress.')
    expect(note.SAVE_NOTE_ADD).toBe('Create account')
    expect(note.SAVE_NOTE_LATER).toBe('Not now')
    expect(note.SAVE_NOTE_REGION).toBe('Keep your progress')
    expect(note.SAVED_ON_THIS_DEVICE).toBe('Your progress is saved on this device.')
    expect(note.SAVE_NOTE_CLOSED).toBe('No problem. You can add your email later from Your account.')
  })
})
