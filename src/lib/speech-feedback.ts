import thresholds from '../../content/checks/speech-thresholds.json' with { type: 'json' }
import { levenshtein, normalizeAnswer } from './grade.ts'

// The speaking feedback rules (factory/jobs/10-speaking-feedback/spec.md,
// "Done when" 7 and 10). Pure TypeScript: no network and no AI. They take the
// approved line in both registers and the speech service's normalised answer,
// and return one feedback class with at most one hint.
//
// - The heard text is compared word by word with the spoken line, with the
//   written line, and (when both have the same number of words) with a line
//   that takes either register's word at each place, because a speech service
//   may write "mä oon" as "minä olen". The best of these counts.
// - Words and letters in a hint come only from the approved line, never from
//   the transcript. The one exception is the heard vowel in "Try ä instead of
//   a.", which is always one of a fixed set of letters.
// - A word the service flags as mispronounced can only turn "clear" into
//   "close", with the hint on that word, and only when the learner said it.
// - v2's normalizeAnswer and levenshtein (src/lib/grade.ts) are used unchanged.
// - Every number is in content/checks/speech-thresholds.json, provisional
//   until risk test 3.

export const SPEECH_RULES = thresholds.rules

export type FeedbackClass = 'clear' | 'close' | 'try_again' | 'not_heard'
export const FEEDBACK_CLASSES: readonly FeedbackClass[] = ['clear', 'close', 'try_again', 'not_heard']

export type Hint =
  | { kind: 'double'; letter: string }
  | { kind: 'single'; letter: string }
  | { kind: 'vowel'; want: string; heard: string }
  | { kind: 'missing'; word: string }
  | { kind: 'off'; word: string }

export type Feedback =
  | { feedbackClass: 'close'; hint: Hint }
  | { feedbackClass: 'clear' | 'try_again' | 'not_heard'; hint?: undefined }

/** One word as the speech service heard it, with its optional flags. */
export interface HeardWord {
  word: string
  /** 0 to 100, from the service's pronunciation assessment. */
  accuracy?: number
  error?: 'none' | 'mispronunciation' | 'omission' | 'insertion' | 'other'
}

/** The speech service's answer, as every provider normalises it. */
export interface HeardAnswer {
  status: 'heard' | 'not_heard'
  heard: string
  words?: readonly HeardWord[]
}

/** The approved line (or form) in both registers. */
export interface TargetLine {
  spoken: string
  written: string
}

export interface SpeechRules {
  maxWordErrorsForClose: number
  maxExtraWords: number
  wordOffMaxChange: number
  mispronunciationScore: number
}

interface Choice {
  norm: string
  /** The word as the approved line writes it, without punctuation. */
  surface: string
}

/** Each place in the line, with the words that count there. */
type Slot = readonly Choice[]

type Step =
  | { op: 'same'; slot: Slot }
  | { op: 'changed'; slot: Slot; heard: string }
  | { op: 'missing'; slot: Slot }
  | { op: 'extra'; heard: string }

const TRIM = /^[^\p{L}]+|[^\p{L}]+$/gu

function lineWords(text: string): Choice[] {
  return text
    .split(/\s+/)
    .map((piece) => ({ norm: normalizeAnswer(piece), surface: piece.replace(TRIM, '') }))
    .filter((word) => word.norm !== '')
}

/** How much of a word changed, from 0 (the same) to 1 (nothing in common). */
function change(a: string, b: string): number {
  if (a === b) return 0
  return levenshtein(a, b) / Math.max(a.length, b.length, 1)
}

function closest(slot: Slot, heard: string): { choice: Choice; change: number } {
  let best = { choice: slot.at(0) ?? { norm: '', surface: '' }, change: 1 }
  for (const choice of slot) {
    const c = change(choice.norm, heard)
    if (c < best.change) best = { choice, change: c }
  }
  return best
}

/** Lines the heard words are compared with: spoken, written, and both mixed. */
function candidates(target: TargetLine): Slot[][] {
  const spoken = lineWords(target.spoken)
  const written = lineWords(target.written)
  const all: Slot[][] = [spoken.map((word) => [word]), written.map((word) => [word])]
  if (spoken.length === written.length && spoken.length > 0) {
    all.push(spoken.map((word, i) => [word, written.at(i) ?? word]))
  }
  return all.filter((slots) => slots.length > 0)
}

/** Word by word alignment: the cheapest way to turn the line into what was heard. */
function align(slots: readonly Slot[], heard: readonly string[]): { steps: Step[]; cost: number } {
  const cols = heard.length + 1
  // The cost table, row by row, in one flat array.
  const table = new Float64Array((slots.length + 1) * cols)
  const cost = (i: number, j: number) => table.at(i * cols + j) ?? 0
  const slotAt = (i: number): Slot => slots.at(i) ?? []
  const wordAt = (j: number): string => heard.at(j) ?? ''
  for (let i = 0; i <= slots.length; i += 1) table[i * cols] = i
  for (let j = 0; j < cols; j += 1) table[j] = j
  for (let i = 1; i <= slots.length; i += 1) {
    for (let j = 1; j < cols; j += 1) {
      const pair = closest(slotAt(i - 1), wordAt(j - 1)).change
      table[i * cols + j] = Math.min(cost(i - 1, j - 1) + pair, cost(i - 1, j) + 1, cost(i, j - 1) + 1)
    }
  }
  const steps: Step[] = []
  let i = slots.length
  let j = heard.length
  while (i > 0 || j > 0) {
    const here = cost(i, j)
    if (i > 0 && j > 0) {
      const slot = slotAt(i - 1)
      const word = wordAt(j - 1)
      const pair = closest(slot, word).change
      if (Math.abs(cost(i - 1, j - 1) + pair - here) < 1e-9) {
        steps.push(pair === 0 ? { op: 'same', slot } : { op: 'changed', slot, heard: word })
        i -= 1
        j -= 1
        continue
      }
    }
    if (i > 0 && Math.abs(cost(i - 1, j) + 1 - here) < 1e-9) {
      steps.push({ op: 'missing', slot: slotAt(i - 1) })
      i -= 1
      continue
    }
    steps.push({ op: 'extra', heard: wordAt(j - 1) })
    j -= 1
  }
  return { steps: steps.reverse(), cost: cost(slots.length, heard.length) }
}

const VOWEL_PAIRS: ReadonlyMap<string, string> = new Map([
  ['ä', 'a'],
  ['a', 'ä'],
  ['ö', 'o'],
  ['o', 'ö'],
  ['y', 'u'],
  ['u', 'y'],
])

/** A one letter hint when the heard word differs from the line's word in one known way. */
export function letterHint(want: string, heard: string): Hint | null {
  if (heard.length === want.length - 1) {
    for (let i = 0; i < want.length - 1; i += 1) {
      if (want.charAt(i) === want.charAt(i + 1) && want.slice(0, i) + want.slice(i + 1) === heard) {
        return { kind: 'double', letter: want.charAt(i) }
      }
    }
  }
  if (heard.length === want.length + 1) {
    for (let i = 0; i < heard.length - 1; i += 1) {
      if (heard.charAt(i) === heard.charAt(i + 1) && heard.slice(0, i) + heard.slice(i + 1) === want) {
        return { kind: 'single', letter: heard.charAt(i) }
      }
    }
  }
  if (heard.length === want.length) {
    const differ: number[] = []
    for (let i = 0; i < want.length; i += 1) if (want.charAt(i) !== heard.charAt(i)) differ.push(i)
    const at = differ.at(0)
    if (differ.length === 1 && at !== undefined) {
      const wantLetter = want.charAt(at)
      const heardLetter = heard.charAt(at)
      if (VOWEL_PAIRS.get(wantLetter) === heardLetter) {
        return { kind: 'vowel', want: wantLetter, heard: heardLetter }
      }
    }
  }
  return null
}

function judge(slots: readonly Slot[], heard: readonly string[], rules: SpeechRules): Feedback {
  const { steps } = align(slots, heard)
  const wrong = steps.filter((step) => step.op === 'changed' || step.op === 'missing')
  const extra = steps.filter((step) => step.op === 'extra').length
  if (extra > rules.maxExtraWords) return { feedbackClass: 'try_again' }
  if (wrong.length === 0) return { feedbackClass: 'clear' }
  if (wrong.length > rules.maxWordErrorsForClose) return { feedbackClass: 'try_again' }
  const step = wrong.at(0)
  if (!step) return { feedbackClass: 'try_again' }
  if (step.op === 'missing') {
    return { feedbackClass: 'close', hint: { kind: 'missing', word: step.slot.at(0)?.surface ?? '' } }
  }
  for (const choice of step.slot) {
    const hint = letterHint(choice.norm, step.heard)
    if (hint) return { feedbackClass: 'close', hint }
  }
  const { choice, change: changed } = closest(step.slot, step.heard)
  if (slots.length === 1 && changed > rules.wordOffMaxChange) return { feedbackClass: 'try_again' }
  return { feedbackClass: 'close', hint: { kind: 'off', word: choice.surface } }
}

const RANK: Record<FeedbackClass, number> = { clear: 0, close: 1, try_again: 2, not_heard: 3 }

function flagged(word: HeardWord, rules: SpeechRules): boolean {
  if (word.error === 'omission' || word.error === 'insertion') return false
  return (
    word.error === 'mispronunciation' ||
    (word.accuracy !== undefined && word.accuracy < rules.mispronunciationScore)
  )
}

/**
 * The feedback class and hint for one try. `rules` defaults to the numbers in
 * content/checks/speech-thresholds.json.
 */
export function classifySpeech(
  target: TargetLine,
  answer: HeardAnswer,
  rules: SpeechRules = SPEECH_RULES,
): Feedback {
  const heard = normalizeAnswer(answer.heard).split(' ').filter(Boolean)
  if (answer.status !== 'heard' || heard.length === 0) return { feedbackClass: 'not_heard' }
  const lines = candidates(target)
  if (lines.length === 0) return { feedbackClass: 'try_again' }
  let best: { feedback: Feedback; cost: number } | null = null
  for (const slots of lines) {
    const feedback = judge(slots, heard, rules)
    const cost = align(slots, heard).cost
    if (
      !best ||
      RANK[feedback.feedbackClass] < RANK[best.feedback.feedbackClass] ||
      (RANK[feedback.feedbackClass] === RANK[best.feedback.feedbackClass] && cost < best.cost)
    ) {
      best = { feedback, cost }
    }
  }
  const result = best?.feedback ?? { feedbackClass: 'try_again' }
  if (result.feedbackClass !== 'clear') return result

  // A flagged word turns clear into close, with the hint on the line's own word.
  const spoken = lineWords(target.spoken)
  const flags = [...(answer.words ?? [])]
    .filter((word) => flagged(word, rules))
    .sort((a, b) => (a.accuracy ?? 0) - (b.accuracy ?? 0))
  for (const flag of flags) {
    const norm = normalizeAnswer(flag.word)
    if (!heard.includes(norm)) continue
    const inLine = spoken.find((word) => word.norm === norm)
    if (inLine) return { feedbackClass: 'close', hint: { kind: 'off', word: inLine.surface } }
  }
  return result
}

/** A piece of a feedback message: English text, or a Finnish word or letter from the line. */
export type MessagePart = string | { fi: string }

export interface FeedbackMessage {
  tone: 'neutral' | 'gentle'
  parts: MessagePart[]
}

/** The one status line message for a try (statement 7). Never a score, a count or a transcript. */
export function feedbackMessage(feedback: Feedback): FeedbackMessage {
  switch (feedback.feedbackClass) {
    case 'clear':
      return { tone: 'neutral', parts: ['Yes, that was clear.'] }
    case 'try_again':
      return { tone: 'gentle', parts: ['Listen to the line once more, then try again.'] }
    case 'not_heard':
      return {
        tone: 'gentle',
        parts: ['That was too quiet to hear. Try again a little closer to the phone.'],
      }
    case 'close':
      return { tone: 'gentle', parts: hintParts(feedback.hint) }
  }
}

function hintParts(hint: Hint): MessagePart[] {
  switch (hint.kind) {
    case 'double':
      return ['Close. Try the double ', { fi: hint.letter }, '.']
    case 'single':
      return ['Close. Try a single ', { fi: hint.letter }, '.']
    case 'vowel':
      return ['Close. Try ', { fi: hint.want }, ' instead of ', { fi: hint.heard }, '.']
    case 'missing':
      return ['Close. Try it again with ', { fi: hint.word }, '.']
    case 'off':
      return ['Close. Listen to ', { fi: hint.word }, ' once more, then try again.']
  }
}

/** The message as plain text, for tests and screen reader checks. */
export function messageText(message: FeedbackMessage): string {
  return message.parts.map((part) => (typeof part === 'string' ? part : part.fi)).join('')
}
