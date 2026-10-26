// The fake speech provider's recorded answers, by name (job 10-speaking-feedback,
// statement 12). Tests pick one with the x-test-speech-fixture header, which
// only the fake reads. Each file says where it came from: built by hand from
// Microsoft's documented response shape, or recorded by the manual workflow
// "Speech fixtures" (.github/workflows/speech-fixtures.yml).

import busy from './busy.json' with { type: 'json' }
import echo from './echo.json' with { type: 'json' }
import line1Clear from './line1-clear.json' with { type: 'json' }
import line1Double from './line1-double.json' with { type: 'json' }
import line1Flagged from './line1-flagged.json' with { type: 'json' }
import line1Missing from './line1-missing.json' with { type: 'json' }
import line1Off from './line1-off.json' with { type: 'json' }
import line1Single from './line1-single.json' with { type: 'json' }
import line1TryAgain from './line1-try-again.json' with { type: 'json' }
import line1Vowel from './line1-vowel.json' with { type: 'json' }
import noMatch from './no-match.json' with { type: 'json' }
import notHeard from './not-heard.json' with { type: 'json' }
import recordedLine1 from './recorded-line-1.json' with { type: 'json' }
import recordedLine2 from './recorded-line-2.json' with { type: 'json' }
import recordedLine5 from './recorded-line-5.json' with { type: 'json' }

export interface SpeechFixture {
  about: string
  source: string
  reference?: string
  /** Answer as if the service heard exactly the reference text. */
  echo?: boolean
  httpStatus?: number
  response?: unknown
}

export const SPEECH_FIXTURES: Readonly<Partial<Record<string, SpeechFixture>>> = {
  busy: busy,
  echo: echo,
  'line1-clear': line1Clear,
  'line1-double': line1Double,
  'line1-flagged': line1Flagged,
  'line1-missing': line1Missing,
  'line1-off': line1Off,
  'line1-single': line1Single,
  'line1-try-again': line1TryAgain,
  'line1-vowel': line1Vowel,
  'no-match': noMatch,
  'not-heard': notHeard,
  'recorded-line-1': recordedLine1,
  'recorded-line-2': recordedLine2,
  'recorded-line-5': recordedLine5,
}

/** The names of the three fixtures the Speech fixtures workflow records, with the line each one voices. */
export const RECORDED_FIXTURES = {
  'recorded-line-1': 'Moi! Mä oon Alex.',
  'recorded-line-2': 'Mist sä oot kotoisin?',
  'recorded-line-5': 'Kiva tavata!',
} as const
