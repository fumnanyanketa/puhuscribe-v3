// The tutor quality check (factory/jobs/16-tutor-step/spec.md, "Done when" 28 and 29), run by hand
// or by the manual workflow "Tutor eval" (.github/workflows/tutor-eval.yml):
//   AI_PROVIDER=fake node scripts/tutor-eval/run.ts          (no key, no cost: proves the harness)
//   ANTHROPIC_API_KEY=... node scripts/tutor-eval/run.ts     (the live model, about $0.05 to $0.20)
//
// It runs the 34 scripted exchanges of content/checks/tutor-eval-scenarios.json (102 learner replies)
// through the real word check, phrase rule, prompt builder and AI provider module, with the met forms
// and lines taken from the approved A1 road dialogues in content/drafts/. Each exchange's learner has
// met every dialogue before the current one. It prints and writes:
//   M1  the share of words in the model's raw replies that are allowed words (the scope's bar: 97 %)
//   M2  the share of turns whose first try has no outside word
//   M3  the share of turns served by an approved line instead of AI, at phrase rule 1.0, 0.75 and 0
//   M4  the share of served AI words that are allowed words (must be 100 %)
//   M5  the share of served tips whose number was offered (must be 100 %)
// Results go to factory/jobs/16-tutor-step/evidence/tutor-eval-results.json, with the served lines
// for the reviewer to read. No key and no header is ever written or printed.

import { mkdirSync, readdirSync, readFileSync, writeFileSync, existsSync } from 'node:fs'
import { join } from 'node:path'
import {
  checkReply,
  metLanguage,
  pickFallback,
  pickOpening,
  sentencesOf,
  TUTOR_ATTEMPTS,
  wordsOf,
  type MetLanguage,
} from '../../src/lib/tutor-words.ts'
import { aiProvider, type AiProvider } from '../../worker/providers/ai.ts'
import { buildPrompt, parseOtso } from '../../worker/tutor-prompt.ts'

const BUDGET_USD = 5
const OUT_DIR = 'factory/jobs/16-tutor-step/evidence'

interface DraftLine {
  speaker: string
  text_puhe: string
  gloss_en: string
  puhe_tokens: { surface: string; kirja?: number }[]
  kirja_tokens: { form?: string; name?: boolean }[]
}
interface Draft {
  brief: { unit: { slug: string; title_en: string; can_do_en: string }; dialogue: { position: number } }
  lines: DraftLine[]
  forms: { id: string; surface_puhe: string }[]
}
interface Dialogue {
  slug: string
  stop: number
  position: number
  draft: Draft
}

function loadDialogues(): Dialogue[] {
  const stops = (
    JSON.parse(readFileSync('content/road/stops.json', 'utf8')) as {
      stops: Record<string, { unit_slug: string }>
    }
  ).stops
  const stopOf = new Map(Object.entries(stops).map(([n, s]) => [s.unit_slug, Number(n)]))
  return readdirSync('content/drafts')
    .filter((slug) => existsSync(join('content/drafts', slug, 'draft.json')))
    .map((slug) => {
      const draft = JSON.parse(readFileSync(join('content/drafts', slug, 'draft.json'), 'utf8')) as Draft
      return {
        slug,
        stop: stopOf.get(draft.brief.unit.slug) ?? 0,
        position: draft.brief.dialogue.position,
        draft,
      }
    })
    .filter((d) => d.stop > 0)
    .sort((a, b) => a.stop - b.stop || a.position - b.position)
}

interface Situation {
  current: Dialogue
  lines: { id: number; speaker: string; spoken: string; gloss: string }[]
  met: MetLanguage
  words: string[]
  examples: string[]
  tipLines: string[]
}

/** The learner of an exchange: every dialogue before the current one, and the current one. */
function situation(all: Dialogue[], slug: string): Situation {
  const index = all.findIndex((d) => d.slug === slug)
  const current = all[index]
  if (!current) throw new Error(`No dialogue ${slug}`)
  const met = all.slice(0, index + 1)
  const spokenForms: string[] = []
  const names: string[] = []
  for (const dialogue of met) {
    const used = new Set<string>()
    for (const line of dialogue.draft.lines) {
      names.push(line.speaker)
      for (const token of line.puhe_tokens) {
        const kirja = token.kirja === undefined ? undefined : line.kirja_tokens[token.kirja - 1]
        if (kirja?.form) used.add(kirja.form)
        else names.push(token.surface)
      }
    }
    for (const form of dialogue.draft.forms) if (used.has(form.id)) spokenForms.push(form.surface_puhe)
  }
  const lines = current.draft.lines.map((l, i) => ({
    id: i + 1,
    speaker: l.speaker,
    spoken: l.text_puhe,
    gloss: l.gloss_en,
  }))
  const others = met
    .slice(0, -1)
    .reverse()
    .flatMap((d) => d.draft.lines.map((l) => l.text_puhe))
  const language = metLanguage({
    spokenForms,
    names,
    lines: met.flatMap((d) => d.draft.lines.map((l) => l.text_puhe)),
  })
  return {
    current,
    lines,
    met: language,
    words: [...language.words],
    examples: [...lines.map((l) => l.spoken), ...others],
    tipLines: [...lines.map((l) => l.spoken), ...others].slice(0, 12),
  }
}

interface Attempt {
  raw: string
  reply: string | null
  words: number
  allowed: number
  outside: string[]
  coverageOk: Record<string, boolean>
}

interface TurnRecord {
  dialogue: string
  stop: number
  turn: number
  replyKind: string
  learner: string
  attempts: Attempt[]
  served:
    | { kind: 'ai'; text: string; meaning: string; tip: number }
    | { kind: 'line'; text: string }
    | { kind: 'end' }
  /** Words of the served AI line, and how many of them are allowed words. */
  servedWords: number
  servedAllowed: number
}

const SETTINGS = [1, 0.75, 0] as const

async function main() {
  const found: AiProvider | null = aiProvider(process.env, (input, init) => fetch(input, init))
  if (!found) {
    console.error('No AI provider: set ANTHROPIC_API_KEY, or AI_PROVIDER=fake for the harness check.')
    process.exit(1)
  }
  const provider: AiProvider = found
  const scenarios = (
    JSON.parse(readFileSync('content/checks/tutor-eval-scenarios.json', 'utf8')) as {
      scenarios: { dialogue: string; replies: { kind: string; text: string }[] }[]
    }
  ).scenarios
  const all = loadDialogues()
  const records: TurnRecord[] = []
  let cost = 0
  let calls = 0
  let tipsServed = 0
  let tipsValid = 0

  async function exchange(scenario: (typeof scenarios)[number]) {
    const s = situation(all, scenario.dialogue)
    const opening = pickOpening(s.lines)
    if (!opening) return
    const history: { you: string; otso: string }[] = []
    for (const [i, learner] of scenario.replies.entries()) {
      const turn = i + 1
      const closing = turn === 3
      const attempts: Attempt[] = []
      let retry: { outside: string[]; unmetPairs: string[] } | null = null
      let served: TurnRecord['served'] | null = null
      for (let attempt = 1; attempt <= TUTOR_ATTEMPTS && !served; attempt += 1) {
        if (cost >= BUDGET_USD) throw new Error(`Stopped at the $${String(BUDGET_USD)} budget.`)
        const prompt = buildPrompt({
          unitTitle: s.current.draft.brief.unit.title_en,
          canDo: s.current.draft.brief.unit.can_do_en,
          dialogue: s.lines.map((l) => ({ speaker: l.speaker, spoken: l.spoken })),
          role: opening.speaker,
          words: s.words,
          examples: s.examples,
          opening: opening.spoken,
          history,
          reply: learner.text,
          turn,
          tipLines: closing ? s.tipLines : [],
          retry,
        })
        let answer
        try {
          answer = await provider.reply(prompt, process.env.TUTOR_EVAL_FIXTURE ?? 'ordinary')
        } catch {
          calls += 1
          attempts.push({ raw: '', reply: null, words: 0, allowed: 0, outside: [], coverageOk: {} })
          continue
        }
        calls += 1
        cost += answer.costUsd
        const parsed = parseOtso(answer.raw)
        const text = parsed?.reply ?? ''
        const words = sentencesOf(text).flat()
        const check = checkReply(text, s.met)
        const coverageOk: Record<string, boolean> = {}
        for (const setting of SETTINGS)
          coverageOk[String(setting)] = parsed !== null && checkReply(text, s.met, setting).ok
        attempts.push({
          raw: text,
          reply: parsed ? text : null,
          words: words.length,
          allowed: words.filter((w) => s.met.words.has(w)).length,
          outside: check.outside,
          coverageOk,
        })
        if (parsed && check.ok) {
          served = { kind: 'ai', text, meaning: parsed.meaning, tip: parsed.tip }
          if (closing && parsed.tip > 0) {
            tipsServed += 1
            if (parsed.tip <= s.tipLines.length) tipsValid += 1
          }
        } else {
          retry = { outside: check.outside, unmetPairs: check.unmetPairs }
        }
      }
      if (!served) {
        const used = [
          opening.id,
          ...s.lines.filter((l) => history.some((h) => h.otso === l.spoken)).map((l) => l.id),
        ]
        const fallback = pickFallback(s.lines, used)
        served = fallback ? { kind: 'line', text: fallback.spoken } : { kind: 'end' }
      }
      const shownWords = served.kind === 'ai' ? wordsOf(served.text) : []
      records.push({
        servedWords: shownWords.length,
        servedAllowed: shownWords.filter((w) => s.met.words.has(w)).length,
        dialogue: scenario.dialogue,
        stop: s.current.stop,
        turn,
        replyKind: learner.kind,
        learner: learner.text,
        attempts,
        served,
      })
      if (served.kind === 'end') break
      history.push({
        you: learner.text,
        otso: served.text,
      })
    }
  }

  // A few exchanges at a time.
  const queue = [...scenarios]
  await Promise.all(
    Array.from({ length: 4 }, async () => {
      for (let next = queue.shift(); next; next = queue.shift()) await exchange(next)
    }),
  )

  const attempts = records.flatMap((r) => r.attempts)
  const rawWords = attempts.reduce((n, a) => n + a.words, 0)
  const rawAllowed = attempts.reduce((n, a) => n + a.allowed, 0)
  const firstClean = records.filter(
    (r) => r.attempts[0] && r.attempts[0].reply !== null && r.attempts[0].outside.length === 0,
  ).length
  const fallbackAt: Record<string, number> = {}
  for (const setting of SETTINGS) {
    fallbackAt[String(setting)] =
      records.filter((r) => !r.attempts.some((a) => a.coverageOk[String(setting)])).length /
      Math.max(1, records.length)
  }
  const servedWords = records.reduce((n, r) => n + r.servedWords, 0)
  const servedAllowed = records.reduce((n, r) => n + r.servedAllowed, 0)
  const m4 = servedWords === 0 ? 1 : servedAllowed / servedWords
  const results = {
    model: provider.model,
    provider: provider.name,
    ranAt: new Date().toISOString(),
    turns: records.length,
    aiCalls: calls,
    costUsd: Math.round(cost * 1e6) / 1e6,
    M1_allowed_word_share_raw: rawWords === 0 ? null : rawAllowed / rawWords,
    M2_first_try_without_outside_word: firstClean / Math.max(1, records.length),
    M3_fallback_share: { strict_1: fallbackAt['1'], middle_0_75: fallbackAt['0.75'], off_0: fallbackAt['0'] },
    M4_served_words_allowed: m4,
    M5_tips_on_list: tipsServed === 0 ? null : tipsValid / tipsServed,
    records,
  }
  mkdirSync(OUT_DIR, { recursive: true })
  writeFileSync(
    join(OUT_DIR, `tutor-eval-results-${provider.name}.json`),
    `${JSON.stringify(results, null, 2)}\n`,
  )
  const pct = (x: number | null) => (x === null ? 'n/a' : `${(x * 100).toFixed(1)} %`)
  console.log(
    `Model ${results.model}, ${String(results.turns)} turns, ${String(calls)} AI calls, $${results.costUsd.toFixed(4)}`,
  )
  console.log(`M1 allowed words in raw replies: ${pct(results.M1_allowed_word_share_raw)}`)
  console.log(`M2 first try with no outside word: ${pct(results.M2_first_try_without_outside_word)}`)
  console.log(
    `M3 served by an approved line: strict ${pct(fallbackAt['1'] ?? 0)}, middle ${pct(fallbackAt['0.75'] ?? 0)}, off ${pct(fallbackAt['0'] ?? 0)}`,
  )
  console.log(`M4 served words allowed: ${pct(m4)}`)
  console.log(`M5 served tips on the list: ${pct(results.M5_tips_on_list)}`)
}

await main()
