import { describe, expect, it } from 'vitest'
import { accountKindOf, carriesSaveNote } from './save-note.ts'
import * as copy from './save-note-copy.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/18-save-progress/spec.md that each test protects.
// The words of the note, checked against the writing rules, and the pure check
// of the complete answer.

/** Every sentence and label of the note, as the learner could read it or hear it. */
function wordsOfTheNote(): string[] {
  return [
    copy.SAVE_NOTE_REGION,
    copy.SAVE_NOTE_SENTENCE,
    copy.SAVE_NOTE_ADD,
    copy.SAVE_NOTE_LATER,
    copy.SAVE_NOTE_CLOSED,
    copy.SAVED_ON_THIS_DEVICE,
  ]
}

const HYPE = /\b(seamless|unlock|elevate|empower|supercharge|game-changer|cutting-edge|effortless)\b/i
const PRESSURE =
  /\b(streaks?|points?|lose|lost|losing|miss|missed|missing|hurry|expires?|expired|expiring|free)\b|last chance/i

/** Every rule of statement 9 that the text breaks, by name. */
function problemsIn(texts: readonly string[]): string[] {
  const all = texts.join(' ')
  const found: string[] = []
  const words = all.split(/\s+/).filter((w) => w !== '')
  if (words.length > 40) found.push('more than 40 words')
  if (/[–—]/.test(all)) found.push('a dash')
  if (/(^|\s)-(\s|$)|[^\w\s]-|-[^\w\s]/.test(all)) found.push('a hyphen used as punctuation')
  if (all.includes(':')) found.push('a colon')
  if (all.includes('!')) found.push('an exclamation mark')
  if (HYPE.test(all)) found.push('a hype word')
  if (PRESSURE.test(all)) found.push('a word of pressure or loss')
  if (/\d/.test(all)) found.push('a digit')
  if (/[äöå]/i.test(all)) found.push('a Finnish letter')
  return found
}

describe('the words of the note', () => {
  it('[save-progress 9] follow the writing rules', () => {
    expect(problemsIn(wordsOfTheNote())).toEqual([])
  })

  // Changed on purpose by the owner on 1 November 2026 (job 19-redesign): the
  // button was "Add your email", the sentence "Add your email to save your progress."
  it('[save-progress 9] hold the labels "Create account" and "Not now"', () => {
    expect(copy.SAVE_NOTE_ADD).toBe('Create account')
    expect(copy.SAVE_NOTE_LATER).toBe('Not now')
    expect(wordsOfTheNote()).toContain('Create account')
    expect(wordsOfTheNote()).toContain('Not now')
  })

  it('[save-progress 9] are the words the owner chose on 1 November 2026', () => {
    expect(copy.SAVE_NOTE_SENTENCE).toBe('Create an account to save your progress.')
    expect(copy.SAVE_NOTE_REGION).toBe('Keep your progress')
    expect(copy.SAVE_NOTE_CLOSED).toBe('No problem. You can add your email later from Your account.')
  })

  it('[save-progress 19] the guest line is the words the owner chose on 1 November 2026', () => {
    expect(copy.SAVED_ON_THIS_DEVICE).toBe('Your progress is saved on this device.')
  })

  it('[save-progress 9] every rule catches a line that breaks it', () => {
    const cases: [string, string][] = [
      ['one two three four five six seven eight nine ten '.repeat(5), 'more than 40 words'],
      ['Add your email — it is quick.', 'a dash'],
      ['Add your email – it is quick.', 'a dash'],
      ['Add your email - it is quick.', 'a hyphen used as punctuation'],
      ['Add your email: it is quick.', 'a colon'],
      ['Add your email!', 'an exclamation mark'],
      ['A seamless way to keep your progress.', 'a hype word'],
      ['Unlock your progress.', 'a hype word'],
      ['Add your email so you do not lose your progress.', 'a word of pressure or loss'],
      ['Keep your streak.', 'a word of pressure or loss'],
      ['Your progress is free to keep.', 'a word of pressure or loss'],
      ['This is your last chance.', 'a word of pressure or loss'],
      ['Hurry and add your email.', 'a word of pressure or loss'],
      ['Add your email in 2 minutes.', 'a digit'],
      ['Lisää sähköpostisi.', 'a Finnish letter'],
    ]
    for (const [text, rule] of cases) {
      expect(problemsIn([text]), text).toContain(rule)
    }
  })

  it('[save-progress 9] the note has nothing in Finnish: no word that carries lang="fi"', () => {
    for (const text of wordsOfTheNote()) expect(text).not.toMatch(/lang=/)
  })

  it('[save-progress 17] the add email address is the one constant that names an app path', () => {
    expect(copy.ADD_EMAIL_PATH).toMatch(/^\/(learn\/)?account\/email$/)
  })
})

describe('the answer to the complete request', () => {
  const answer = (status: number, body: unknown) => ({ status, body })

  it('[save-progress 3] carries a note only for a saved answer with a word this screen knows', () => {
    expect(carriesSaveNote(answer(200, { saved: true, saveNote: 'first' }))).toBe(true)
    expect(carriesSaveNote(answer(200, { saved: true, saveNote: 'reminder' }))).toBe(true)
    expect(carriesSaveNote(answer(200, { saved: true }))).toBe(false)
    expect(carriesSaveNote(answer(200, { saved: true, saveNote: 'none' }))).toBe(false)
    expect(carriesSaveNote(answer(200, { saved: true, saveNote: 'later' }))).toBe(false)
    expect(carriesSaveNote(answer(200, { saved: true, saveNote: true }))).toBe(false)
  })

  it('[save-progress 2] never carries a note when the save failed, was refused or the network failed', () => {
    expect(carriesSaveNote(answer(503, { saved: true, saveNote: 'first' }))).toBe(false)
    expect(carriesSaveNote(answer(401, { saveNote: 'first' }))).toBe(false)
    expect(carriesSaveNote(answer(409, { error: 'step_out_of_order', saveNote: 'first' }))).toBe(false)
    expect(carriesSaveNote(answer(200, { saveNote: 'first' }))).toBe(false)
    expect(carriesSaveNote(answer(200, null))).toBe(false)
    expect(carriesSaveNote(answer(200, 'first'))).toBe(false)
    expect(carriesSaveNote(null)).toBe(false)
  })
})

describe('the kind of account that GET /api/me names', () => {
  const me = (status: number, body: unknown) => ({ status, body })

  it('[save-progress 19] only a clear guest answer gives the guest line', () => {
    expect(accountKindOf(me(200, { kind: 'guest' }))).toBe('guest')
    expect(accountKindOf(me(200, { kind: 'email', email: 'a@example.com' }))).toBe('email')
    expect(accountKindOf(me(200, { kind: 'none' }))).toBe('other')
    expect(accountKindOf(me(401, { kind: 'guest' }))).toBe('other')
    expect(accountKindOf(me(503, { kind: 'guest' }))).toBe('other')
    expect(accountKindOf(me(200, null))).toBe('other')
    expect(accountKindOf(me(200, 'guest'))).toBe('other')
    expect(accountKindOf(me(200, { kind: 'Guest' }))).toBe('other')
    expect(accountKindOf(null)).toBe('other')
  })
})
