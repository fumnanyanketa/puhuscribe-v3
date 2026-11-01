import { describe, expect, it } from 'vitest'
import { cardOf, newWordsFrom, newWordsHeading } from './new-words.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md.

const word = (extra: Record<string, unknown> = {}) => ({
  form: { lemma: 'minä', formName: 'I', why: 'Why.', spoken: 'mä', written: 'minä', ...extra },
  spokenAudio: '/audio/unit/1-puhe.mp3',
  writtenAudio: '/audio/unit/1-kirja.mp3',
})

describe('the new words of the complete answer', () => {
  it('[redesign 33] reads a clean list, with the word meanings when they are there', () => {
    const words = newWordsFrom({ saved: true, newWords: [word(), word({ meaning: 'I', baseMeaning: 'I' })] })
    expect(words).toHaveLength(2)
    expect(words[0]?.form).toEqual({
      lemma: 'minä',
      formName: 'I',
      why: 'Why.',
      spoken: 'mä',
      written: 'minä',
    })
    expect(words[1]?.form.meaning).toBe('I')
  })

  it('[redesign 33] an answer without new words, or an odd one, gives none', () => {
    expect(newWordsFrom({ saved: true })).toEqual([])
    expect(newWordsFrom(null)).toEqual([])
    expect(newWordsFrom({ newWords: 'many' })).toEqual([])
    expect(newWordsFrom({ newWords: [word({ spoken: '' })] })).toEqual([])
    expect(newWordsFrom({ newWords: Array.from({ length: 25 }, () => word()) })).toEqual([])
  })

  it('[redesign 33] [security] an audio address outside /audio/ on this address is refused, so no file loads from elsewhere', () => {
    for (const bad of [
      'https://example.com/a.mp3',
      '//example.com/a.mp3',
      'data:audio/wav;base64,AAAA',
      '/other/a.mp3',
      '/audio/../secret.mp3',
      'audio/a.mp3',
      '/audio/',
    ]) {
      expect(newWordsFrom({ newWords: [{ ...word(), spokenAudio: bad }] }), bad).toEqual([])
    }
    expect(newWordsFrom({ newWords: [{ ...word(), writtenAudio: 'javascript:alert(1)' }] })).toEqual([])
  })

  it('[redesign 33] the heading counts the chips, one or many', () => {
    expect(newWordsHeading(1)).toBe('1 new word')
    expect(newWordsHeading(11)).toBe('11 new words')
  })

  it('[redesign 33] a chip opens a word card with both registers and the line audio', () => {
    const first = newWordsFrom({ newWords: [word({ meaning: 'I' })] })[0]
    expect(first).toBeDefined()
    expect(cardOf(first)).toEqual({
      word: 'mä',
      baseForm: 'minä',
      formName: 'I',
      why: 'Why.',
      meaning: 'I',
      spoken: { text: 'mä', audio: '/audio/unit/1-puhe.mp3' },
      written: { text: 'minä', audio: '/audio/unit/1-kirja.mp3' },
    })
  })
})
