import Anthropic from '@anthropic-ai/sdk'
import { AI_FIXTURES, type AiFixture } from './fixtures/ai/index.ts'

// The AI provider for the tutor, Otso (factory/jobs/16-tutor-step/spec.md, "Done when" 26 and 27).
// This is the only file in the Worker that calls an AI service and the only file that reads its
// key. Swapping the provider changes this file only.
//
// AI_PROVIDER picks one:
// - "anthropic" (also when the setting is missing): Anthropic's Messages API with the
//   ANTHROPIC_API_KEY Worker secret (owner's call 1, answered 3 November 2026: Anthropic's own API,
//   processed in the United States; the privacy notice says so). The model is Claude Haiku 5.5.
// - "fake": replays recorded answers from worker/providers/fixtures/ai/, picked by the
//   x-test-tutor-fixture header, which only the fake reads. wrangler.jsonc and the deploy workflows
//   never set it.
//
// Every call returns its model, token counts and cost, from the dated price table below, and the
// Worker writes them into the call's tutor_calls row. Nothing here writes to the log: no prompt, no
// answer, no key. A failure never carries the provider's answer body.

export interface AiEnv {
  AI_PROVIDER?: string
  ANTHROPIC_API_KEY?: string
}

export type Fetch = (input: string | URL | Request, init?: RequestInit) => Promise<Response>

/** The model Otso runs on (owner's call 1: the small model first). */
export const TUTOR_MODEL = 'claude-haiku-5-5'

/**
 * US dollars per million tokens. Source: Anthropic's pricing page,
 * https://platform.claude.com/docs/en/about-claude/pricing, read 30 October 2026 by the spec writer
 * (Haiku 5.5 $0.10 in and $0.50 out, Sonnet 5.5 $2 and $10), checked against the Claude API
 * reference table again on 3 November 2026. Prompts up to 100,000 tokens; Otso's are far smaller.
 */
export const AI_PRICES = {
  date: '2026-11-03',
  perMillion: {
    'claude-haiku-5-5': { input: 0.1, output: 0.5 },
    'claude-sonnet-5-5': { input: 2, output: 10 },
  } as Readonly<Record<string, { input: number; output: number }>>,
}

/**
 * Models that need the provider to keep prompts and answers (Anthropic's data retention page: these
 * require 30 day retention). The provider refuses to start with one of them.
 */
export const MODELS_THAT_KEEP_DATA = [
  'claude-fable-5',
  'claude-fable-5-1',
  'claude-mythos-5',
  'claude-mythos-5-1',
] as const

/** Where the provider processes the text, for the notice. */
export const AI_REGION = 'the United States'

/** The longest answer Otso may write, in tokens (statement 20). */
export const MAX_OUTPUT_TOKENS = 300
/** How long one call may take (statement 20). */
export const AI_TIMEOUT_MS = 15_000

export type AiFault = 'timeout' | 'busy' | 'refused' | 'failed'

/** The AI service gave no usable answer. Carries no prompt, answer or key. */
export class AiCallFailed extends Error {
  readonly fault: AiFault
  constructor(fault: AiFault) {
    super(`The AI call did not finish (${fault}).`)
    this.name = 'AiCallFailed'
    this.fault = fault
  }
}

/** What the prompt builder hands the provider. `facts` are for the fake only; the real one sends the text. */
export interface TutorPrompt {
  system: string
  user: string
  facts: {
    /** Today's dialogue's spoken lines, in order. */
    dialogue: string[]
    /** How many tip lines were offered (0 before the closing turn). */
    tipCount: number
  }
}

export interface AiAnswer {
  /** The provider's text, which should be JSON of the shape in OTSO_SCHEMA. Never logged. */
  raw: string
  model: string
  inputTokens: number
  outputTokens: number
  costUsd: number
}

export interface AiProvider {
  name: 'anthropic' | 'fake'
  model: string
  /** Sends one prompt. `testFixture` is the x-test-tutor-fixture header; only the fake reads it. */
  reply: (prompt: TutorPrompt, testFixture: string | null) => Promise<AiAnswer>
}

/** The JSON Otso must answer with. tip is the number of an offered line, or 0 for none. */
export const OTSO_SCHEMA = {
  type: 'object',
  properties: {
    reply: { type: 'string' },
    meaning: { type: 'string' },
    tip: { type: 'integer' },
  },
  required: ['reply', 'meaning', 'tip'],
  additionalProperties: false,
} as const

/** The cost of one call, from the dated price table, rounded to 8 decimals. */
export function costUsd(model: string, inputTokens: number, outputTokens: number): number {
  const price = AI_PRICES.perMillion[model]
  if (!price) return 0
  const cost = (Math.max(0, inputTokens) * price.input + Math.max(0, outputTokens) * price.output) / 1e6
  return Math.round(cost * 1e8) / 1e8
}

function faultOf(error: unknown, timedOut: boolean): AiFault {
  if (timedOut) return 'timeout'
  if (error instanceof Anthropic.RateLimitError || error instanceof Anthropic.InternalServerError)
    return 'busy'
  if (error instanceof Anthropic.AuthenticationError || error instanceof Anthropic.PermissionDeniedError) {
    return 'refused'
  }
  return 'failed'
}

function anthropicProvider(key: string, model: string, fetchImpl: Fetch): AiProvider {
  const client = new Anthropic({
    apiKey: key,
    // One call per reserved slot: a retry is the Worker's choice, never the library's.
    maxRetries: 0,
    timeout: AI_TIMEOUT_MS,
    logLevel: 'off',
    fetch: fetchImpl,
  })
  return {
    name: 'anthropic',
    model,
    // The test fixture header is ignored here on purpose.
    async reply(prompt) {
      // AbortController and a timer, as every runtime has them (AGENTS.md, lesson from job 2).
      const controller = new AbortController()
      let timedOut = false
      const timer = setTimeout(() => {
        timedOut = true
        controller.abort()
      }, AI_TIMEOUT_MS)
      try {
        const message = await client.messages.create(
          {
            model,
            max_tokens: MAX_OUTPUT_TOKENS,
            // Short, plain answers: no thinking, low effort (Haiku 5.5 allows thinking off at high or below).
            thinking: { type: 'disabled' },
            output_config: { effort: 'low', format: { type: 'json_schema', schema: OTSO_SCHEMA } },
            system: prompt.system,
            messages: [{ role: 'user', content: prompt.user }],
          },
          { signal: controller.signal },
        )
        const raw =
          message.stop_reason === 'refusal'
            ? ''
            : message.content.flatMap((block) => (block.type === 'text' ? [block.text] : [])).join('')
        const inputTokens = message.usage.input_tokens
        const outputTokens = message.usage.output_tokens
        return { raw, model, inputTokens, outputTokens, costUsd: costUsd(model, inputTokens, outputTokens) }
      } catch (error) {
        throw new AiCallFailed(faultOf(error, timedOut))
      } finally {
        clearTimeout(timer)
      }
    },
  }
}

/** The fake's answer for a fixture. */
export function fixtureAnswer(fixture: AiFixture, prompt: TutorPrompt): AiAnswer {
  if (fixture.fault) throw new AiCallFailed(fixture.fault)
  const line = (n: number) => prompt.facts.dialogue[n] ?? prompt.facts.dialogue[0] ?? ''
  const reply = (fixture.reply ?? '{line1}').replace(/\{line(\d)\}/g, (_, n: string) => line(Number(n)))
  const raw =
    fixture.raw ??
    JSON.stringify({
      reply,
      meaning: fixture.meaning ?? '',
      tip: Math.min(fixture.tip ?? 0, prompt.facts.tipCount + 5),
    })
  return { raw, model: 'fake', inputTokens: 0, outputTokens: 0, costUsd: 0 }
}

function fakeProvider(): AiProvider {
  return {
    name: 'fake',
    model: 'fake',
    reply(prompt, testFixture) {
      const name = testFixture ?? 'ordinary'
      const fixture = Object.hasOwn(AI_FIXTURES, name) ? AI_FIXTURES[name] : undefined
      if (!fixture) return Promise.reject(new AiCallFailed('failed'))
      try {
        return Promise.resolve(fixtureAnswer(fixture, prompt))
      } catch (error) {
        return Promise.reject(error instanceof Error ? error : new AiCallFailed('failed'))
      }
    },
  }
}

/** True when the model may be used: it does not need the provider to keep conversations. */
export function modelAllowed(model: string): boolean {
  return (
    !(MODELS_THAT_KEEP_DATA as readonly string[]).includes(model) &&
    Object.hasOwn(AI_PRICES.perMillion, model)
  )
}

/**
 * The provider the settings pick, or null when the tutor is not available: no key, an unknown
 * provider name, or a model that keeps conversations or has no price. Without a provider the step
 * is left out of sessions (statement 1).
 */
export function aiProvider(env: AiEnv, fetchImpl: Fetch, model: string = TUTOR_MODEL): AiProvider | null {
  const choice = env.AI_PROVIDER?.trim().toLowerCase() ?? ''
  if (choice === 'fake') return fakeProvider()
  if (choice !== '' && choice !== 'anthropic') return null
  const key = env.ANTHROPIC_API_KEY?.trim() ?? ''
  if (!key || !modelAllowed(model)) return null
  return anthropicProvider(key, model, fetchImpl)
}
