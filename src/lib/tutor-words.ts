import thresholds from '../../content/checks/tutor-thresholds.json' with { type: 'json' }

// The tutor's rules, in code (factory/jobs/16-tutor-step/spec.md, "Done when" 7, 8, 12 to 15).
// Pure TypeScript with no network, shared by the Worker (which runs every check before anything
// is shown) and the app (which picks Otso's opening line the same way the Worker does).
//
// - The word check: every word of a reply must be the spoken shape of a form the learner has met,
//   or a name from a dialogue they met. The learner's own words never extend the list.
// - The phrase rule (owner's call 2, answer C): every pair of neighbouring words in a sentence must
//   occur next to each other in an approved line the learner met. How strict is one number in
//   content/checks/tutor-thresholds.json.
// - The English meaning: short, plain letters only, never says anything is wrong.
// No Voikko at run time (PRD 7.3: v3.1).

/** One exchange is Otso's opening, then this many turns (a learner reply and Otso's answer). */
export const TUTOR_TURNS = 3
/** AI calls for one turn: the first try and two retries. */
export const TUTOR_ATTEMPTS = 3
/** The longest reply a learner may send, after trimming. */
export const MAX_TUTOR_REPLY = 120
/** The phrase rule's setting: 1 is strict, 0.75 the middle setting, 0 switches it off. */
export const MIN_PAIR_COVERAGE: number = thresholds.min_pair_coverage_per_sentence

/** Lowercases with Finnish rules (ä, ö and å stay themselves). */
export function finnishLower(text: string): string {
  return text.toLocaleLowerCase('fi-FI')
}

/** Letters, spaces and . , ! ? ' - only. Anything else (digits, symbols, emoji, markup, addresses) fails. */
const ALLOWED_CHARACTERS = /^[\p{L}\s.,!?'-]*$/u
const SENTENCE_END = /[.!?]+/u

/** The words of one piece of text, lowercased, without the punctuation around them. */
export function wordsOf(text: string): string[] {
  return finnishLower(text)
    .split(/[\s.,!?]+/u)
    .map((word) => word.replace(/^['-]+|['-]+$/gu, ''))
    .filter((word) => word !== '')
}

/** The sentences of a text, each as its words. A sentence with no words is left out. */
export function sentencesOf(text: string): string[][] {
  return text
    .split(SENTENCE_END)
    .map(wordsOf)
    .filter((words) => words.length > 0)
}

/** The neighbouring pairs of a sentence, as "first second". */
export function pairsOf(words: readonly string[]): string[] {
  const pairs: string[] = []
  for (let i = 0; i + 1 < words.length; i += 1) pairs.push(`${words[i] ?? ''} ${words[i + 1] ?? ''}`)
  return pairs
}

/** What the learner has met, as the checks need it. Built per request from approved rows only. */
export interface MetLanguage {
  /** Allowed words, lowercased. */
  words: ReadonlySet<string>
  /** Neighbouring word pairs of every met approved line's spoken text, lowercased. */
  pairs: ReadonlySet<string>
}

export interface MetSource {
  /** The spoken shapes (forms.surface_puhe) of the met approved forms. */
  spokenForms: readonly string[]
  /** Names in the met dialogues: speaker names, and spoken words that have no form. */
  names: readonly string[]
  /** The spoken text of every approved line of every met dialogue. */
  lines: readonly string[]
}

/** Builds the allowed words and pairs. Nothing the learner typed is ever passed here. */
export function metLanguage(source: MetSource): MetLanguage {
  const words = new Set<string>()
  for (const shape of [...source.spokenForms, ...source.names])
    for (const word of wordsOf(shape)) words.add(word)
  const pairs = new Set<string>()
  for (const line of source.lines)
    for (const sentence of sentencesOf(line)) for (const pair of pairsOf(sentence)) pairs.add(pair)
  return { words, pairs }
}

export interface ReplyCheck {
  ok: boolean
  /** True when the text holds a character other than letters, spaces and . , ! ? ' - */
  badCharacters: boolean
  /** Words that are not allowed words, each once, in order. */
  outside: string[]
  /** Neighbouring pairs not found in a met line, in sentences under the phrase rule's setting. */
  unmetPairs: string[]
}

/** The share of a sentence's neighbouring pairs found in met lines. A one word sentence passes. */
export function pairCoverage(words: readonly string[], pairs: ReadonlySet<string>): number {
  const all = pairsOf(words)
  if (all.length === 0) return 1
  return all.filter((pair) => pairs.has(pair)).length / all.length
}

/** Checks one line Otso would say. `minPairCoverage` defaults to the setting in the thresholds file. */
export function checkReply(text: string, met: MetLanguage, minPairCoverage = MIN_PAIR_COVERAGE): ReplyCheck {
  const badCharacters = !ALLOWED_CHARACTERS.test(text)
  const sentences = sentencesOf(text)
  const outside: string[] = []
  for (const word of sentences.flat()) if (!met.words.has(word) && !outside.includes(word)) outside.push(word)
  const unmetPairs: string[] = []
  if (minPairCoverage > 0) {
    for (const sentence of sentences) {
      if (pairCoverage(sentence, met.pairs) >= minPairCoverage) continue
      for (const pair of pairsOf(sentence))
        if (!met.pairs.has(pair) && !unmetPairs.includes(pair)) unmetPairs.push(pair)
    }
  }
  const empty = sentences.length === 0
  return {
    ok: !badCharacters && !empty && outside.length === 0 && unmetPairs.length === 0,
    badCharacters,
    outside,
    unmetPairs,
  }
}

// The learner's reply --------------------------------------------------------------------------------

const CONTROL = /\p{Cc}/u

/** The learner's reply, trimmed, or null when it is empty, too long or holds a control character. */
export function cleanReply(text: unknown): string | null {
  if (typeof text !== 'string') return null
  const trimmed = text.trim()
  if (trimmed.length < 1 || trimmed.length > MAX_TUTOR_REPLY) return null
  if (CONTROL.test(trimmed)) return null
  return trimmed
}

// The English meaning ----------------------------------------------------------------------------------

const MEANING_SHAPE = /^[A-Za-z .,!?'-]+$/
const MEANING_BANNED = ['wrong', 'incorrect', 'mistake', 'error', 'bad', 'fail']

/** The meaning, trimmed, when it may be shown; null otherwise (statement 15). Plain text only. */
export function cleanMeaning(text: unknown): string | null {
  if (typeof text !== 'string') return null
  const trimmed = text.trim().replace(/\s+/g, ' ')
  if (trimmed === '' || !MEANING_SHAPE.test(trimmed)) return null
  const words = trimmed.split(' ')
  if (words.length > 20) return null
  const lower = trimmed.toLowerCase()
  if (/www|https?|\.com|\.fi\b/.test(lower)) return null
  if (lower.split(/[^a-z]+/).some((word) => MEANING_BANNED.some((banned) => word.startsWith(banned)))) {
    return null
  }
  return trimmed
}

// Otso's opening and fallback lines ----------------------------------------------------------------------

export interface DialogueLineText {
  id: number
  speaker: string
  /** The spoken text of the line. */
  spoken: string
}

/** Otso's opening: the first line whose spoken text ends with a question mark, else the first line. */
export function pickOpening<T extends DialogueLineText>(lines: readonly T[]): T | undefined {
  return lines.find((line) => line.spoken.trim().endsWith('?')) ?? lines[0]
}

/**
 * The approved line that serves a turn when the AI's tries fail: the next line of today's dialogue,
 * after the opening, spoken by the opening's speaker and not used yet. Undefined when none is left.
 */
export function pickFallback<T extends DialogueLineText>(
  lines: readonly T[],
  usedIds: readonly number[],
): T | undefined {
  const opening = pickOpening(lines)
  if (!opening) return undefined
  const start = lines.indexOf(opening)
  return lines.find(
    (line, index) => index > start && line.speaker === opening.speaker && !usedIds.includes(line.id),
  )
}
