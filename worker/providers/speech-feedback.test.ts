import voicePy from '../../scripts/generate/providers/voice.py?raw'
import moduleSource from './speech-feedback.ts?raw'
import { afterEach, describe, expect, it, vi } from 'vitest'
import { encodeWav } from '../../src/lib/wav.ts'
import { RECORDED_FIXTURES, SPEECH_FIXTURES } from './fixtures/speech/index.ts'
import {
  EU_REGIONS,
  SPEECH_PRICES,
  SpeechCheckFailed,
  assessmentHeader,
  azureSettingsProblem,
  fixtureAnswer,
  mapAzureAnswer,
  recordAzureAnswer,
  speechProvider,
  type Fetch,
  type SpeechEnv,
} from './speech-feedback.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.
// The speech provider module, with a fake fetch: no test here reaches Azure.

const KEY = 'unit-test-azure-key-not-real'
const AZURE: SpeechEnv = { AZURE_SPEECH_KEY: KEY, AZURE_SPEECH_REGION: 'italynorth', AZURE_SPEECH_TIER: 'F0' }
const WAV = encodeWav(new Float32Array(16_000).fill(0.1))
const LINE = 'Moi! Mä oon Alex.'

interface Sent {
  url: string
  init: RequestInit
}

function fakeFetch(...answers: (Response | Error)[]): { fetch: Fetch; sent: Sent[] } {
  const sent: Sent[] = []
  return {
    sent,
    fetch: (input, init) => {
      sent.push({ url: input instanceof Request ? input.url : String(input), init: init ?? {} })
      const next = answers.shift() ?? new Response('{}', { status: 500 })
      return next instanceof Error ? Promise.reject(next) : Promise.resolve(next)
    },
  }
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

const SUCCESS = {
  RecognitionStatus: 'Success',
  Offset: 400000,
  Duration: 11000000,
  NBest: [
    {
      Confidence: 0.9,
      Lexical: 'moi mä oon alex',
      Display: 'Moi, mä oon Alex.',
      AccuracyScore: 90,
      Words: [
        { Word: 'moi', AccuracyScore: 98, ErrorType: 'None' },
        { Word: 'mä', AccuracyScore: 97, ErrorType: 'None' },
        { Word: 'oon', AccuracyScore: 40, ErrorType: 'Mispronunciation' },
        { Word: 'alex', AccuracyScore: 99, ErrorType: 'None' },
      ],
    },
  ],
}

afterEach(() => {
  vi.useRealTimers()
})

describe('the azure provider', () => {
  it('[speak 12] calls the short audio REST API in the resource region, fi-FI, detailed, with the assessment header', async () => {
    const { fetch, sent } = fakeFetch(json(SUCCESS))
    const provider = speechProvider(AZURE, fetch)
    expect(provider?.name).toBe('azure')
    await provider?.check(WAV, LINE, null)
    expect(sent).toHaveLength(1)
    const url = new URL(sent[0]?.url ?? '')
    expect(url.origin).toBe('https://italynorth.stt.speech.microsoft.com')
    expect(url.pathname).toBe('/speech/recognition/conversation/cognitiveservices/v1')
    expect(Object.fromEntries(url.searchParams)).toEqual({ language: 'fi-FI', format: 'detailed' })
    const headers = new Headers(sent[0]?.init.headers)
    expect(headers.get('ocp-apim-subscription-key')).toBe(KEY)
    expect(headers.get('content-type')).toBe('audio/wav; codecs=audio/pcm; samplerate=16000')
    expect(sent[0]?.init.method).toBe('POST')
    expect(sent[0]?.init.body).toBe(WAV)
    expect(sent[0]?.init.signal).toBeInstanceOf(AbortSignal)
    const assessment = headers.get('pronunciation-assessment') ?? ''
    const decoded = new TextDecoder().decode(Uint8Array.from(atob(assessment), (c) => c.charCodeAt(0)))
    expect(JSON.parse(decoded)).toEqual({
      ReferenceText: LINE,
      GradingSystem: 'HundredMark',
      Granularity: 'Word',
      Dimension: 'Comprehensive',
      EnableMiscue: true,
      EnableProsodyAssessment: false,
    })
  })

  it('[speak 12] builds the header with JSON.stringify, so quotes and Finnish letters in a line stay intact', () => {
    const line = 'Hän sanoi: "Ootsä täält?" \\ ja lähti.'
    const decoded = new TextDecoder().decode(
      Uint8Array.from(atob(assessmentHeader(line)), (c) => c.charCodeAt(0)),
    )
    expect((JSON.parse(decoded) as { ReferenceText: string }).ReferenceText).toBe(line)
  })

  it('[speak 12] maps the answer: Lexical, and each word with its error type and accuracy', async () => {
    const { fetch } = fakeFetch(json(SUCCESS))
    const answer = await speechProvider(AZURE, fetch)?.check(WAV, LINE, null)
    expect(answer).toEqual({
      status: 'heard',
      heard: 'moi mä oon alex',
      words: [
        { word: 'moi', accuracy: 98, error: 'none' },
        { word: 'mä', accuracy: 97, error: 'none' },
        { word: 'oon', accuracy: 40, error: 'mispronunciation' },
        { word: 'alex', accuracy: 99, error: 'none' },
      ],
    })
  })

  it('[speak 12] also reads the scores when Azure nests them in PronunciationAssessment', () => {
    expect(
      mapAzureAnswer({
        RecognitionStatus: 'Success',
        NBest: [
          {
            Lexical: 'kiva tavata',
            Words: [{ Word: 'kiva', PronunciationAssessment: { AccuracyScore: 55, ErrorType: 'Omission' } }],
          },
        ],
      }),
    ).toEqual({
      status: 'heard',
      heard: 'kiva tavata',
      words: [{ word: 'kiva', accuracy: 55, error: 'omission' }],
    })
  })

  it('[speak 12] silence and no match are "not heard"; an error status is a failed check', () => {
    for (const status of ['NoMatch', 'InitialSilenceTimeout', 'BabbleTimeout']) {
      expect(mapAzureAnswer({ RecognitionStatus: status })).toEqual({ status: 'not_heard', heard: '' })
    }
    expect(() => mapAzureAnswer({ RecognitionStatus: 'Error' })).toThrow(SpeechCheckFailed)
    expect(() => mapAzureAnswer('not json at all')).toThrow(SpeechCheckFailed)
  })

  it('[speak 12] retries once on 429, then gives up as busy', async () => {
    vi.useFakeTimers()
    const once = fakeFetch(json({}, 429), json(SUCCESS))
    const first = speechProvider(AZURE, once.fetch)?.check(WAV, LINE, null)
    await vi.runAllTimersAsync()
    expect((await first)?.heard).toBe('moi mä oon alex')
    expect(once.sent).toHaveLength(2)

    const twice = fakeFetch(json({}, 429), json({}, 429), json(SUCCESS))
    const second = speechProvider(AZURE, twice.fetch)?.check(WAV, LINE, null)
    const result = expect(second).rejects.toMatchObject({ fault: 'busy' })
    await vi.runAllTimersAsync()
    await result
    expect(twice.sent).toHaveLength(2)
  })

  it('[speak 12] answers refused for a bad key, failed for other errors, and stops waiting after 10 seconds', async () => {
    await expect(
      speechProvider(AZURE, fakeFetch(json({}, 401)).fetch)?.check(WAV, LINE, null),
    ).rejects.toMatchObject({
      fault: 'refused',
    })
    await expect(
      speechProvider(AZURE, fakeFetch(json({}, 500)).fetch)?.check(WAV, LINE, null),
    ).rejects.toMatchObject({
      fault: 'failed',
    })
    await expect(
      speechProvider(AZURE, fakeFetch(new TypeError('network')).fetch)?.check(WAV, LINE, null),
    ).rejects.toMatchObject({ fault: 'failed' })

    vi.useFakeTimers()
    let aborted = false
    const hanging: Fetch = (_input, init) =>
      new Promise((_resolve, reject) => {
        init?.signal?.addEventListener('abort', () => {
          aborted = true
          reject(new DOMException('aborted', 'AbortError'))
        })
      })
    const check = speechProvider(AZURE, hanging)?.check(WAV, LINE, null)
    const result = expect(check).rejects.toMatchObject({ fault: 'timeout' })
    await vi.advanceTimersByTimeAsync(9_999)
    expect(aborted).toBe(false)
    await vi.advanceTimersByTimeAsync(1)
    await result
    expect(aborted).toBe(true)
  })

  it('[speak 12] ignores the test fixture header', async () => {
    const { fetch, sent } = fakeFetch(json(SUCCESS))
    const answer = await speechProvider(AZURE, fetch)?.check(WAV, LINE, 'not-heard')
    expect(sent).toHaveLength(1)
    expect(answer?.status).toBe('heard')
  })
})

describe('the EU region rule', () => {
  it('[speak 13] the provider refuses to start outside the EU list, with eastus refused', () => {
    const { fetch, sent } = fakeFetch()
    for (const region of [
      'eastus',
      'westus2',
      'uksouth',
      'switzerlandnorth',
      'norwayeast',
      'italynorth.evil.example',
    ]) {
      expect(speechProvider({ ...AZURE, AZURE_SPEECH_REGION: region }, fetch), region).toBeNull()
      expect(azureSettingsProblem({ ...AZURE, AZURE_SPEECH_REGION: region })).toBe('region_not_in_eu')
    }
    expect(sent).toHaveLength(0)
  })

  it('[speak 13] every region on the list is in the EU and names its country for the consent text', () => {
    expect(EU_REGIONS).toEqual({
      northeurope: 'Ireland',
      westeurope: 'the Netherlands',
      swedencentral: 'Sweden',
      francecentral: 'France',
      germanywestcentral: 'Germany',
      italynorth: 'Italy',
      polandcentral: 'Poland',
    })
    for (const region of Object.keys(EU_REGIONS)) {
      expect(speechProvider({ ...AZURE, AZURE_SPEECH_REGION: region }, fakeFetch().fetch)?.regionName).toBe(
        EU_REGIONS[region],
      )
    }
  })

  it("[speak 13] the list matches the content pipeline's voice provider list", () => {
    const voice = voicePy
    const block = /EU_REGIONS = frozenset\(\s*\{([^}]*)\}/.exec(voice)?.[1] ?? ''
    const pipeline = [...block.matchAll(/"([a-z]+)"/g)].map((match) => match[1]).sort()
    expect(pipeline.length).toBeGreaterThan(3)
    expect(Object.keys(EU_REGIONS).sort()).toEqual(pipeline)
  })

  it('[speak 13] without a key, a region or a known price tier, speech feedback is not available', () => {
    const fetch = fakeFetch().fetch
    expect(speechProvider({ ...AZURE, AZURE_SPEECH_KEY: '' }, fetch)).toBeNull()
    expect(speechProvider({ ...AZURE, AZURE_SPEECH_REGION: undefined }, fetch)).toBeNull()
    expect(speechProvider({ ...AZURE, AZURE_SPEECH_TIER: 'S9' }, fetch)).toBeNull()
    expect(speechProvider({}, fetch)).toBeNull()
    expect(speechProvider({ ...AZURE, SPEECH_FEEDBACK_PROVIDER: 'other' }, fetch)).toBeNull()
    expect(speechProvider({ ...AZURE, SPEECH_FEEDBACK_PROVIDER: 'azure' }, fetch)?.name).toBe('azure')
  })
})

describe('the cost of a check', () => {
  it('[speak 20] comes from a dated price table: one hour on the paid tier is $1.00, the free tier is $0', () => {
    expect(SPEECH_PRICES.date).toBe('2026-10-21')
    expect(SPEECH_PRICES.usdPerAudioHour).toEqual({ F0: 0, S0: 1 })
    const source = moduleSource
    expect(source).toContain('https://prices.azure.com/api/retail/prices')
    expect(source).toContain(
      'https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/',
    )
    const paid = speechProvider({ ...AZURE, AZURE_SPEECH_TIER: 'S0' }, fakeFetch().fetch)
    expect(paid?.costUsd(3_600_000)).toBe(1)
    expect(paid?.costUsd(1500)).toBe(0.00041667)
    expect(speechProvider(AZURE, fakeFetch().fetch)?.costUsd(1500)).toBe(0)
    expect(speechProvider({ SPEECH_FEEDBACK_PROVIDER: 'fake' }, fakeFetch().fetch)?.costUsd(1500)).toBe(0)
  })
})

describe('the fake provider', () => {
  it('[speak 12] replays the fixture the test header names, and answers with the line itself when none is named', async () => {
    const fake = speechProvider({ SPEECH_FEEDBACK_PROVIDER: 'fake' }, fakeFetch().fetch)
    expect(fake?.name).toBe('fake')
    expect(await fake?.check(WAV, LINE, null)).toEqual({
      status: 'heard',
      heard: 'moi mä oon alex',
      words: ['moi', 'mä', 'oon', 'alex'].map((word) => ({ word, accuracy: 95, error: 'none' })),
    })
    expect((await fake?.check(WAV, LINE, 'line1-double'))?.heard).toBe('moi mä on alex')
    expect(await fake?.check(WAV, LINE, 'not-heard')).toEqual({ status: 'not_heard', heard: '' })
    await expect(fake?.check(WAV, LINE, 'busy')).rejects.toMatchObject({ fault: 'busy' })
    await expect(fake?.check(WAV, LINE, 'no-such-fixture')).rejects.toMatchObject({ fault: 'failed' })
    await expect(fake?.check(WAV, LINE, 'constructor')).rejects.toMatchObject({ fault: 'failed' })
  })

  it('[speak 23] every fixture file is listed, says where it came from, and holds no key', () => {
    const raw = import.meta.glob<string>('./fixtures/speech/*.json', {
      query: '?raw',
      import: 'default',
      eager: true,
    })
    const files = Object.keys(raw).map((path) => path.replace('./fixtures/speech/', ''))
    expect(files.map((name) => name.replace(/\.json$/, '')).sort()).toEqual(
      Object.keys(SPEECH_FIXTURES).sort(),
    )
    for (const [name, fixture] of Object.entries(SPEECH_FIXTURES)) {
      expect(fixture?.about, name).toMatch(/Microsoft's documentation|recorded/)
      expect(['hand-built', 'recorded']).toContain(fixture?.source)
      if (fixture?.source === 'hand-built') expect(fixture.about, name).toContain('not recorded from Azure')
      const text = raw[`./fixtures/speech/${name}.json`] ?? ''
      expect(text, name).not.toMatch(/Ocp-Apim|subscription|x-test-speech-fixture|authorization/i)
    }
    for (const [name, line] of Object.entries(RECORDED_FIXTURES)) {
      expect(SPEECH_FIXTURES[name]?.reference).toBe(line)
      if (SPEECH_FIXTURES[name]) expect(fixtureAnswer(SPEECH_FIXTURES[name], line).status).toBe('heard')
    }
  })
})

describe('recording a fixture answer', () => {
  it("[speak 23] returns Azure's raw answer for the workflow, and refuses without EU settings", async () => {
    const { fetch, sent } = fakeFetch(json(SUCCESS))
    expect(await recordAzureAnswer(AZURE, WAV, LINE, fetch)).toEqual({ httpStatus: 200, response: SUCCESS })
    expect(new URL(sent[0]?.url ?? '').host).toBe('italynorth.stt.speech.microsoft.com')
    await expect(
      recordAzureAnswer({ ...AZURE, AZURE_SPEECH_REGION: 'eastus' }, WAV, LINE, fetch),
    ).rejects.toMatchObject({ fault: 'refused' })
  })
})
