// The fake AI provider's answers, by name (factory/jobs/16-tutor-step/spec.md, "Done when" 26).
// Tests and the local evidence pick one with the x-test-tutor-fixture header, which only the fake
// reads. Written by hand from the shape Otso must answer with (worker/providers/ai.ts, OTSO_SCHEMA).
// {lineN} stands for the spoken text of line N of today's dialogue (from 0), so a fake answer is
// made only of approved words.

export interface AiFixture {
  about: string
  /** Otso's reply, with {lineN} placeholders. */
  reply?: string
  meaning?: string
  /** The number of the offered tip line, or 0. */
  tip?: number
  /** The provider's whole text, used as it is (for malformed answers). */
  raw?: string
  /** The call fails this way. */
  fault?: 'timeout' | 'busy' | 'refused' | 'failed'
}

export const AI_FIXTURES: Readonly<Record<string, AiFixture>> = {
  ordinary: {
    about: 'Answers with the second line of the dialogue, a short meaning and the first tip line.',
    reply: '{line1}',
    meaning: 'A line from the dialogue.',
    tip: 1,
  },
  'outside-word': {
    about: 'Plants a word the learner has not met in every answer, so every try fails the word check.',
    reply: '{line1} banaani',
    meaning: 'A line with an extra word.',
  },
  'bad-meaning': {
    about: 'A meaning that says the learner is wrong: it must not be shown.',
    reply: '{line1}',
    meaning: 'That was wrong, try again.',
  },
  'invalid-tip': {
    about: 'Names a tip line that was not offered.',
    reply: '{line1}',
    meaning: 'A line from the dialogue.',
    tip: 99,
  },
  'not-json': { about: 'Answers with text that is not JSON.', raw: 'Hei! Mitä kuuluu?' },
  error: { about: 'The service fails.', fault: 'failed' },
  timeout: { about: 'The service takes too long.', fault: 'timeout' },
}
