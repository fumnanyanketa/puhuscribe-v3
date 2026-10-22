import { readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'
import {
  FEEDBACK_CLASSES,
  SPEECH_RULES,
  classifySpeech,
  type Hint,
  type HeardWord,
} from '../../src/lib/speech-feedback.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.
//
// The speaking feedback golden set (statement 11) and the thresholds file
// (statement 10). Kept out of src/ so no file under content/ is ever imported
// by app code except the rules' own thresholds. `npm run eval:speech` runs
// this file on its own and prints the pass rate; `npm test` runs it with every
// other unit test, so the pull request checks run it too. It fails below the
// PRD's 90 percent, recorded in content/checks/speech-thresholds.json.
//
// Honest limit: the rules and the labels were both written in job 10, so a
// pass proves the rules do what the labels say. Whether the labels match a
// native ear is checked by the native reviewer and measured in risk test 3.

interface GoldenCase {
  id: string
  covers: string
  line: number
  spoken: string
  written: string
  status: 'heard' | 'not_heard'
  heard: string
  words?: HeardWord[]
  expected: { class: string; hint?: Hint }
}

const golden = JSON.parse(readFileSync('content/checks/speaking-feedback-golden.json', 'utf8')) as {
  reviewed: boolean
  cases: GoldenCase[]
}
const thresholds = JSON.parse(readFileSync('content/checks/speech-thresholds.json', 'utf8')) as {
  status: string
  rules: Record<string, number>
  goldenSet: { minPassRate: number }
}
const sheet = readFileSync('docs/risk-tests/test-2-voice-lines.md', 'utf8')

function run(golden: GoldenCase): { pass: boolean; got: string } {
  const result = classifySpeech(
    { spoken: golden.spoken, written: golden.written },
    { status: golden.status, heard: golden.heard, words: golden.words },
  )
  const got = { class: result.feedbackClass, ...(result.hint ? { hint: result.hint } : {}) }
  return { pass: JSON.stringify(got) === JSON.stringify(golden.expected), got: JSON.stringify(got) }
}

describe('the speaking feedback golden set', () => {
  it('[speak 11] holds 30 cases on lines 1 to 10 of the voice test sheet, marked not reviewed', () => {
    expect(golden.cases).toHaveLength(30)
    expect(golden.reviewed).toBe(false)
    expect(new Set(golden.cases.map((c) => c.id)).size).toBe(30)
    for (const c of golden.cases) {
      expect(c.line, c.id).toBeGreaterThanOrEqual(1)
      expect(c.line, c.id).toBeLessThanOrEqual(10)
      const row = sheet.split('\n').find((text) => text.startsWith(`| ${String(c.line)} |`)) ?? ''
      expect(row, c.id).toContain(`| ${c.spoken} | ${c.written} |`)
      expect(FEEDBACK_CLASSES, c.id).toContain(c.expected.class)
    }
  })

  it('[speak 11] covers every kind of case the spec names', () => {
    const covers = golden.cases.map((c) => c.covers).join('\n')
    for (const kind of [
      'exact',
      'punctuation and capitals only',
      'spoken heard as written',
      'doubled consonant missed (tt)',
      'long vowel shortened',
      'single letter doubled',
      'ä and a swapped',
      'one word missing',
      'one extra word',
      'two or more words wrong',
      'nothing heard',
      'flagged mispronunciation',
    ]) {
      expect(covers, kind).toContain(kind)
    }
    const hints = new Set(golden.cases.map((c) => c.expected.hint?.kind ?? c.expected.class))
    expect([...hints].sort()).toEqual(
      ['clear', 'double', 'missing', 'not_heard', 'off', 'single', 'try_again', 'vowel'].sort(),
    )
  })

  it('[speak 11] passes at the PRD rate or better', () => {
    const results = golden.cases.map((c) => ({ id: c.id, covers: c.covers, ...run(c) }))
    const passed = results.filter((r) => r.pass).length
    const rate = passed / results.length
    const failed = results.filter((r) => !r.pass).map((r) => `${r.id} (${r.covers}): got ${r.got}`)
    console.log(
      `Speaking feedback golden set: ${String(passed)} of ${String(results.length)} passed, ` +
        `pass rate ${(rate * 100).toFixed(1)} percent (needs ${String(thresholds.goldenSet.minPassRate * 100)} percent).` +
        (failed.length > 0 ? `\nNot as labelled:\n${failed.join('\n')}` : ''),
    )
    expect(rate).toBeGreaterThanOrEqual(thresholds.goldenSet.minPassRate)
  })
})

describe('the thresholds file', () => {
  it('[speak 10] every number the rules use comes from content/checks/speech-thresholds.json, marked provisional', () => {
    expect(thresholds.status).toMatch(/provisional until risk test 3/)
    expect(SPEECH_RULES).toEqual(thresholds.rules)
    expect(Object.keys(thresholds.rules).sort()).toEqual(
      ['maxExtraWords', 'maxWordErrorsForClose', 'mispronunciationScore', 'wordOffMaxChange'].sort(),
    )
  })
})
