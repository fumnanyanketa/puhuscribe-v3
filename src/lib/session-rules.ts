import type { SessionLine, SessionWord } from './session-types.ts'

// The two fixed rules of the first session loop
// (factory/jobs/8-first-session/spec.md, Decisions 4 and 5). Both are plain
// functions of the dialogue, so the same session always gets the same result.

/** One comprehension question: a line and up to three English meanings to choose from. */
export interface Question {
  line: SessionLine
  choices: string[]
  /** The index in choices of the line's own meaning. */
  answer: number
}

const MAX_QUESTIONS = 3
const MAX_WRONG_CHOICES = 2

function formKey(word: SessionWord): string | null {
  const form = word.form
  return form ? [form.lemma, form.formName, form.spoken, form.written].join('\u0000') : null
}

/** How many different reviewable word forms a line holds, in both registers. */
export function reviewableForms(line: SessionLine): number {
  return new Set([...line.spoken, ...line.written].flatMap((word) => formKey(word) ?? [])).size
}

// A small seeded random order (FNV-1a hash, then mulberry32), so the order is
// fixed by the session id and survives a reload.
function seed(text: string): number {
  let hash = 0x811c9dc5
  for (let i = 0; i < text.length; i += 1) {
    hash ^= text.charCodeAt(i)
    hash = Math.imul(hash, 0x01000193) >>> 0
  }
  return hash
}

function random(seedValue: number): () => number {
  let state = seedValue
  return () => {
    state = (state + 0x6d2b79f5) >>> 0
    let t = state
    t = Math.imul(t ^ (t >>> 15), t | 1)
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61)
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}

export function shuffled<T>(items: readonly T[], key: string): T[] {
  const next = random(seed(key))
  const out = [...items]
  for (let i = out.length - 1; i > 0; i -= 1) {
    const j = Math.floor(next() * (i + 1))
    const a = out[i]
    out[i] = out[j]
    out[j] = a
  }
  return out
}

/**
 * Decision 4. The lines with the most reviewable words (ties go to the earlier
 * line), up to three, asked in dialogue order. Each offers the line's own
 * meaning and up to two meanings of other lines in the dialogue. Which wrong
 * meanings, and the order of the choices, are fixed by the session id.
 */
export function pickQuestions(lines: readonly SessionLine[], sessionId: string): Question[] {
  const chosen = lines
    .map((line, index) => ({ line, index, forms: reviewableForms(line) }))
    .sort((a, b) => b.forms - a.forms || a.index - b.index)
    .slice(0, MAX_QUESTIONS)
    .sort((a, b) => a.index - b.index)
  return chosen.map(({ line }) => {
    const others = [
      ...new Set(lines.filter((other) => other.id !== line.id).map((other) => other.gloss)),
    ].filter((gloss) => gloss !== line.gloss)
    const wrong = shuffled(others, `${sessionId}:${String(line.id)}:wrong`).slice(0, MAX_WRONG_CHOICES)
    const choices = shuffled([line.gloss, ...wrong], `${sessionId}:${String(line.id)}:order`)
    return { line, choices, answer: choices.indexOf(line.gloss) }
  })
}

function wordsWithForms(line: SessionLine): number {
  return line.spoken.filter((word) => word.form).length
}

/**
 * Decision 5. The one sentence the learner can now say: the shortest line
 * (by spoken words) with at least two words that have readable forms; ties go
 * to the earlier line. If no line has two, the shortest line with one; if none
 * has any, the shortest line.
 */
export function pickFinishLine(lines: readonly SessionLine[]): SessionLine | null {
  const shortest = (pool: readonly SessionLine[]) =>
    pool.reduce<SessionLine | null>(
      (best, line) => (best === null || line.spoken.length < best.spoken.length ? line : best),
      null,
    )
  return (
    shortest(lines.filter((line) => wordsWithForms(line) >= 2)) ??
    shortest(lines.filter((line) => wordsWithForms(line) >= 1)) ??
    shortest(lines)
  )
}
