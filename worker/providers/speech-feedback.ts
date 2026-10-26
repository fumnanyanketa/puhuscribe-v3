import type { HeardAnswer, HeardWord } from '../../src/lib/speech-feedback.ts'
import { SPEECH_FIXTURES, type SpeechFixture } from './fixtures/speech/index.ts'

// The speech feedback provider (factory/jobs/10-speaking-feedback/spec.md,
// "Done when" 12, 13, 20 and 23). This is the only file that calls a speech
// service, and the only file that reads the Azure key or names an Azure
// address (tests/speech-provider-rules.test.ts checks both). Swapping the
// provider after risk test 3 changes this file only.
//
// SPEECH_FEEDBACK_PROVIDER picks one:
// - "azure" (also when the setting is missing): Azure's speech to text REST
//   API for short audio, locale fi-FI, with scripted pronunciation assessment
//   (the approved line is the reference text). The resource region must be on
//   the EU list below, or the provider refuses to start.
// - "fake": replays recorded answers from worker/providers/fixtures/speech/,
//   picked by the x-test-speech-fixture header. Only the browser tests and unit
//   tests use it; wrangler.jsonc and the deploy workflows never set it.
//
// Nothing here writes to the log: no audio, transcript, reference text or key.

export interface SpeechEnv {
  SPEECH_FEEDBACK_PROVIDER?: string
  AZURE_SPEECH_KEY?: string
  AZURE_SPEECH_REGION?: string
  AZURE_SPEECH_TIER?: string
}

export type Fetch = (input: string | URL | Request, init?: RequestInit) => Promise<Response>

/** The only regions audio may go to: Azure regions inside the EU, with the country named in the consent text. */
export const EU_REGIONS: Readonly<Record<string, string>> = {
  northeurope: 'Ireland',
  westeurope: 'the Netherlands',
  swedencentral: 'Sweden',
  francecentral: 'France',
  germanywestcentral: 'Germany',
  italynorth: 'Italy',
  polandcentral: 'Poland',
}

/**
 * What one hour of audio costs, per Azure Speech price tier, in US dollars.
 * Pronunciation assessment is billed as speech to text.
 * Sources, read 21 October 2026:
 * - F0 (free tier, 5 audio hours a month): Azure Speech pricing page,
 *   https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/
 * - S0 (pay as you go): Azure retail prices API, North Europe, "S1 Speech To
 *   Text", $1.00 per hour,
 *   https://prices.azure.com/api/retail/prices?$filter=armRegionName%20eq%20'northeurope'%20and%20contains(productName,%20'Speech')
 */
export const SPEECH_PRICES = {
  date: '2026-10-21',
  usdPerAudioHour: { F0: 0, S0: 1 } as Readonly<Record<string, number>>,
}

export type SpeechFault = 'busy' | 'timeout' | 'refused' | 'failed'

/** The speech service could not give an answer. Carries no audio, text or key. */
export class SpeechCheckFailed extends Error {
  readonly fault: SpeechFault
  constructor(fault: SpeechFault) {
    super(`The speech check did not finish (${fault}).`)
    this.name = 'SpeechCheckFailed'
    this.fault = fault
  }
}

export interface SpeechProvider {
  /** A short label stored with every attempt. */
  name: 'azure' | 'fake'
  /** The EU country the audio goes to, for the consent text; null for the fake. */
  regionName: string | null
  /**
   * Sends one 16 kHz mono WAV with the approved reference text and returns
   * the normalised answer. `testFixture` is the x-test-speech-fixture header;
   * only the fake reads it.
   */
  check: (wav: Uint8Array, reference: string, testFixture: string | null) => Promise<HeardAnswer>
  /** What a check of this many milliseconds of audio costs, from the dated price table. */
  costUsd: (audioMs: number) => number
}

const TIMEOUT_MS = 10_000
const RETRY_WAIT_MS = 500
const LOCALE = 'fi-FI'

function wait(ms: number): Promise<void> {
  return new Promise((resolve) => {
    setTimeout(resolve, ms)
  })
}

function base64(bytes: Uint8Array): string {
  let binary = ''
  for (let i = 0; i < bytes.length; i += 0x8000) {
    binary += String.fromCharCode(...bytes.subarray(i, i + 0x8000))
  }
  return btoa(binary)
}

/** The Pronunciation-Assessment header: JSON, as UTF-8, in base64. */
export function assessmentHeader(reference: string): string {
  const json = JSON.stringify({
    ReferenceText: reference,
    GradingSystem: 'HundredMark',
    Granularity: 'Word',
    Dimension: 'Comprehensive',
    EnableMiscue: true,
    EnableProsodyAssessment: false,
  })
  return base64(new TextEncoder().encode(json))
}

function record(value: unknown): Record<string, unknown> {
  return typeof value === 'object' && value !== null ? (value as Record<string, unknown>) : {}
}

function errorType(value: unknown): HeardWord['error'] {
  switch (typeof value === 'string' ? value.toLowerCase() : '') {
    case 'none':
      return 'none'
    case 'mispronunciation':
      return 'mispronunciation'
    case 'omission':
      return 'omission'
    case 'insertion':
      return 'insertion'
    case '':
      return undefined
    default:
      return 'other'
  }
}

/** Turns Azure's detailed answer into the normalised answer the rules take. */
export function mapAzureAnswer(body: unknown): HeardAnswer {
  const answer = record(body)
  const status = answer.RecognitionStatus
  if (status === 'NoMatch' || status === 'InitialSilenceTimeout' || status === 'BabbleTimeout') {
    return { status: 'not_heard', heard: '' }
  }
  if (status !== 'Success') throw new SpeechCheckFailed('failed')
  const nBest = Array.isArray(answer.NBest) ? answer.NBest : []
  const best = record(nBest[0])
  const heard = [best.Lexical, best.Display, answer.DisplayText].find((text) => typeof text === 'string')
  const words: HeardWord[] = (Array.isArray(best.Words) ? best.Words : []).flatMap((item) => {
    const word = record(item)
    const assessment = record(word.PronunciationAssessment)
    if (typeof word.Word !== 'string') return []
    const accuracy = word.AccuracyScore ?? assessment.AccuracyScore
    return [
      {
        word: word.Word,
        accuracy: typeof accuracy === 'number' ? accuracy : undefined,
        error: errorType(word.ErrorType ?? assessment.ErrorType),
      },
    ]
  })
  return { status: 'heard', heard: typeof heard === 'string' ? heard : '', words }
}

function costFor(usdPerHour: number): (audioMs: number) => number {
  return (audioMs) => Math.round((Math.max(0, audioMs) / 3_600_000) * usdPerHour * 1e8) / 1e8
}

function azureUrl(region: string): string {
  return (
    `https://${region}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1` +
    `?language=${LOCALE}&format=detailed`
  )
}

/** One request to Azure, with the 10 second limit. Throws timeout or failed when no answer came. */
async function azureRequest(
  key: string,
  region: string,
  wav: Uint8Array,
  reference: string,
  fetchImpl: Fetch,
): Promise<Response> {
  const controller = new AbortController()
  const timer = setTimeout(() => {
    controller.abort()
  }, TIMEOUT_MS)
  try {
    return await fetchImpl(azureUrl(region), {
      method: 'POST',
      headers: {
        'Ocp-Apim-Subscription-Key': key,
        'Content-Type': 'audio/wav; codecs=audio/pcm; samplerate=16000',
        Accept: 'application/json',
        'Pronunciation-Assessment': assessmentHeader(reference),
      },
      body: wav,
      signal: controller.signal,
    })
  } catch {
    throw new SpeechCheckFailed(controller.signal.aborted ? 'timeout' : 'failed')
  } finally {
    clearTimeout(timer)
  }
}

function azureProvider(key: string, region: string, usdPerHour: number, fetchImpl: Fetch): SpeechProvider {
  const once = (wav: Uint8Array, reference: string) => azureRequest(key, region, wav, reference, fetchImpl)

  return {
    name: 'azure',
    regionName: EU_REGIONS[region] ?? null,
    costUsd: costFor(usdPerHour),
    // The test fixture header is ignored here on purpose.
    async check(wav, reference) {
      let res = await once(wav, reference)
      if (res.status === 429) {
        await res.body?.cancel()
        await wait(RETRY_WAIT_MS)
        res = await once(wav, reference)
      }
      if (res.status === 429) {
        await res.body?.cancel()
        throw new SpeechCheckFailed('busy')
      }
      if (res.status === 401 || res.status === 403) {
        await res.body?.cancel()
        throw new SpeechCheckFailed('refused')
      }
      if (!res.ok) {
        await res.body?.cancel()
        throw new SpeechCheckFailed('failed')
      }
      let body: unknown
      try {
        body = await res.json()
      } catch {
        throw new SpeechCheckFailed('failed')
      }
      return mapAzureAnswer(body)
    },
  }
}

/** The fake's answer for a fixture, as if Azure had sent it. */
export function fixtureAnswer(fixture: SpeechFixture, reference: string): HeardAnswer {
  if (fixture.echo) {
    const words = reference
      .split(/\s+/)
      .map((word) => word.replace(/^[^\p{L}]+|[^\p{L}]+$/gu, '').toLowerCase())
      .filter(Boolean)
    return mapAzureAnswer({
      RecognitionStatus: 'Success',
      NBest: [
        {
          Lexical: words.join(' '),
          Words: words.map((word) => ({ Word: word, AccuracyScore: 95, ErrorType: 'None' })),
        },
      ],
    })
  }
  const status = fixture.httpStatus ?? 200
  if (status === 429) throw new SpeechCheckFailed('busy')
  if (status === 401 || status === 403) throw new SpeechCheckFailed('refused')
  if (status !== 200) throw new SpeechCheckFailed('failed')
  return mapAzureAnswer(fixture.response)
}

function fakeProvider(): SpeechProvider {
  return {
    name: 'fake',
    regionName: null,
    costUsd: () => 0,
    check(_wav, reference, testFixture) {
      const name = testFixture ?? 'echo'
      const fixture = Object.hasOwn(SPEECH_FIXTURES, name) ? SPEECH_FIXTURES[name] : undefined
      if (!fixture) return Promise.reject(new SpeechCheckFailed('failed'))
      try {
        return Promise.resolve(fixtureAnswer(fixture, reference))
      } catch (error) {
        return Promise.reject(error instanceof Error ? error : new SpeechCheckFailed('failed'))
      }
    },
  }
}

/** Why the Azure provider cannot start, or null when it can. Never names the key's value. */
export function azureSettingsProblem(
  env: SpeechEnv,
): 'no_key' | 'no_region' | 'region_not_in_eu' | 'no_price' | null {
  if (!env.AZURE_SPEECH_KEY?.trim()) return 'no_key'
  const region = env.AZURE_SPEECH_REGION?.trim().toLowerCase() ?? ''
  if (!region) return 'no_region'
  if (!Object.hasOwn(EU_REGIONS, region)) return 'region_not_in_eu'
  const tier = env.AZURE_SPEECH_TIER?.trim().toUpperCase() ?? ''
  if (!Object.hasOwn(SPEECH_PRICES.usdPerAudioHour, tier)) return 'no_price'
  return null
}

/**
 * The provider the settings pick, or null when speech feedback is not
 * available: the Azure key or region is missing, the region is not in the
 * EU, or the price tier is not in the dated price table.
 */
export function speechProvider(env: SpeechEnv, fetchImpl: Fetch): SpeechProvider | null {
  const choice = env.SPEECH_FEEDBACK_PROVIDER?.trim().toLowerCase() ?? ''
  if (choice === 'fake') return fakeProvider()
  if (choice !== '' && choice !== 'azure') return null
  if (azureSettingsProblem(env) !== null) return null
  const region = (env.AZURE_SPEECH_REGION ?? '').trim().toLowerCase()
  const tier = (env.AZURE_SPEECH_TIER ?? '').trim().toUpperCase()
  return azureProvider(
    (env.AZURE_SPEECH_KEY ?? '').trim(),
    region,
    SPEECH_PRICES.usdPerAudioHour[tier] ?? 0,
    fetchImpl,
  )
}

/**
 * Sends one clip to Azure and returns its raw answer, for the manual "Speech
 * fixtures" workflow (scripts/speech/record-fixtures.ts), which commits the
 * answer as a fixture for the fake. Never used by a Worker route.
 */
export async function recordAzureAnswer(
  env: SpeechEnv,
  wav: Uint8Array,
  reference: string,
  fetchImpl: Fetch,
): Promise<{ httpStatus: number; response: unknown }> {
  if (azureSettingsProblem(env) !== null) throw new SpeechCheckFailed('refused')
  const region = (env.AZURE_SPEECH_REGION ?? '').trim().toLowerCase()
  const res = await azureRequest((env.AZURE_SPEECH_KEY ?? '').trim(), region, wav, reference, fetchImpl)
  if (!res.ok) {
    await res.body?.cancel()
    throw new SpeechCheckFailed(
      res.status === 429 ? 'busy' : res.status === 401 || res.status === 403 ? 'refused' : 'failed',
    )
  }
  return { httpStatus: res.status, response: await res.json() }
}
