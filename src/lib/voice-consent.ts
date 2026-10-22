// The voice consent text and its version label
// (factory/jobs/10-speaking-feedback/spec.md, "Done when" 1 and 2). The one
// place this text lives. The Worker writes VOICE_NOTICE_VERSION into every
// consents row it adds; the browser never chooses it. A unit test
// (src/lib/voice-consent.test.ts) fails when the text changes and the label
// does not.
//
// Draft wording for the owner to approve at the end of the job (owner's call
// 2, answered A: transcripts kept 90 days).

export const VOICE_NOTICE_VERSION = 'voice-2026-10.1'

export interface VoiceNotice {
  heading: string
  paragraphs: string[]
  keepBox: string
  changeLater: string
  turnOn: string
  notNow: string
}

/**
 * The consent screen's text. `region` is the EU country of the speech
 * service, such as "Italy", or null when the settings name none (the test
 * provider).
 */
export function voiceNotice(region: string | null): VoiceNotice {
  const where = region ? `in the EU, in ${region}` : 'in the EU'
  return {
    heading: 'Speaking feedback',
    paragraphs: [
      'To give you feedback, PuhuScribe records your voice only while the record button is on, for a few seconds per line.',
      `The recording goes from this phone through PuhuScribe's server to Microsoft's speech service ${where}. The service turns it into text, and PuhuScribe compares that text with the line.`,
      'Microsoft does not keep your recording, and PuhuScribe deletes it as soon as your feedback is ready.',
      'PuhuScribe keeps the text the service heard and how close it was, to check that the feedback works. That text is deleted after 90 days.',
    ],
    keepBox:
      'Keep my recordings so I can hear my progress. We keep your first and latest try of each line for 90 days. You can delete them at any time.',
    changeLater: 'You can change both choices at any time in Voice settings.',
    turnOn: 'Turn on speaking feedback',
    notNow: 'Not now',
  }
}
