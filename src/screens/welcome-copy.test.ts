import { describe, expect, it } from 'vitest'
import * as copy from './welcome-copy.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/15-onboarding/spec.md ([onboarding N]). They check the wording
// rules on the one file that holds the welcome's words, so an edit at the
// owner's approval is held to the same rules. Each rule has a "catches" test
// that feeds it text that breaks it and expects a finding.

/** Every piece of text the welcome shows, in reading order. */
const PIECES: string[] = [
  copy.WELCOME_HEADING,
  copy.WELCOME_SESSION,
  copy.WELCOME_TWO_FORMS,
  copy.WELCOME_SPOKEN_LABEL,
  copy.WELCOME_SPOKEN,
  copy.WELCOME_WRITTEN_LABEL,
  copy.WELCOME_WRITTEN,
  copy.WELCOME_ORDER,
]

const HYPE = [
  'seamless',
  'unlock',
  'elevate',
  'empower',
  'supercharge',
  'game-changer',
  'cutting-edge',
  'effortless',
]
const BANNED_WORDS = ['Day One', 'Sprint', 'streak', 'confetti', 'points', 'level', 'quiz', 'placement']

function wordCount(pieces: string[]): number {
  return pieces
    .join(' ')
    .split(/\s+/)
    .filter((word) => word.length > 0).length
}

/** Sentences (not the heading or labels) that hold a dash, a colon or a spaced hyphen. */
function punctuationProblems(sentences: string[]): string[] {
  return sentences.filter((text) => /[–—:]/.test(text) || /(^|\s)-(\s|$)/.test(text))
}

function wordsFound(text: string, words: string[]): string[] {
  return words.filter((word) => new RegExp(`(^|[^\\p{L}])${word}(?=$|[^\\p{L}])`, 'iu').test(text))
}

const SENTENCES = [
  copy.WELCOME_SESSION,
  copy.WELCOME_TWO_FORMS,
  copy.WELCOME_SPOKEN,
  copy.WELCOME_WRITTEN,
  copy.WELCOME_ORDER,
]

describe('the welcome words (spec "Welcome wording")', () => {
  it('[onboarding 2] hold exactly the approved draft', () => {
    expect(copy.WELCOME_HEADING).toBe('Welcome to PuhuScribe')
    expect(copy.WELCOME_SESSION).toBe(
      'You tap any word to see what it is, and you say the lines back. The words you met come back for review on later days.',
    )
    expect(copy.WELCOME_TWO_FORMS).toBe('Every line comes in two forms, and you can hear both.')
    expect(copy.WELCOME_SPOKEN_LABEL).toBe('Spoken')
    expect(copy.WELCOME_SPOKEN).toBe('How people in Finland talk day to day, in shops and at work.')
    expect(copy.WELCOME_WRITTEN_LABEL).toBe('Written')
    expect(copy.WELCOME_WRITTEN).toBe('How Finnish is written in books and on forms.')
    expect(copy.WELCOME_ORDER).toBe('Spoken comes first. The written form sits under it.')
  })

  it('[onboarding 2] come to at most 80 words, counting the heading and the band labels', () => {
    expect(wordCount(PIECES)).toBeLessThanOrEqual(80)
    // The draft is 73 words; the count itself is checked so a miscount shows.
    expect(wordCount(PIECES)).toBe(73)
  })

  it('[onboarding 2] have no em dash, no hyphen used as punctuation and no colon in the sentences', () => {
    expect(punctuationProblems(SENTENCES)).toEqual([])
  })

  it('[onboarding 2] name no hype word and none of the banned product words', () => {
    const all = PIECES.join(' ')
    expect(wordsFound(all, HYPE)).toEqual([])
    expect(wordsFound(all, BANNED_WORDS)).toEqual([])
  })

  it('[onboarding 2] contain the labels Spoken and Written, in that order', () => {
    expect(copy.WELCOME_SPOKEN_LABEL).toBe('Spoken')
    expect(copy.WELCOME_WRITTEN_LABEL).toBe('Written')
    const all = PIECES.join(' | ')
    expect(all.indexOf('Spoken')).toBeLessThan(all.indexOf('Written'))
  })

  it('[onboarding 4] hold no Finnish: no ä, ö or å in the words (the file itself is checked in tests/onboarding-rules.test.ts)', () => {
    expect(PIECES.join(' ')).not.toMatch(/[äöåÄÖÅ]/)
  })
})

describe('the rules catch what they are meant to catch', () => {
  it('[onboarding 2] the word count sees 81 words', () => {
    expect(wordCount([Array.from({ length: 81 }, () => 'word').join(' ')])).toBe(81)
  })

  it('[onboarding 2] the punctuation rule catches an em dash, an en dash, a colon and a spaced hyphen', () => {
    for (const bad of [
      'Two forms — both heard.',
      'Two forms – both heard.',
      'Here is the thing: two forms.',
      'Two forms - both heard.',
    ]) {
      expect(punctuationProblems([bad]), bad).toEqual([bad])
    }
    expect(punctuationProblems(['Day to day, in shops.'])).toEqual([])
  })

  it('[onboarding 2] the word rules catch a hype word and a banned word, whatever the case', () => {
    expect(wordsFound('It is Seamless and effortless.', HYPE)).toEqual(['seamless', 'effortless'])
    expect(wordsFound('Pick your Level in the Quiz.', BANNED_WORDS)).toEqual(['level', 'quiz'])
    expect(wordsFound('The Day One Sprint.', BANNED_WORDS)).toEqual(['Day One', 'Sprint'])
    // Whole words only: "points" does not match "pointed".
    expect(wordsFound('She pointed at it.', BANNED_WORDS)).toEqual([])
  })

  it('[onboarding 4] the Finnish letter rule catches ä, ö and å', () => {
    for (const bad of ['Hyvää', 'työ', 'Åbo']) expect(bad).toMatch(/[äöåÄÖÅ]/)
  })
})
