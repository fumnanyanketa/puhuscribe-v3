import { describe, expect, it } from 'vitest'
import {
  SPEECH_RULES,
  classifySpeech,
  feedbackMessage,
  letterHint,
  messageText,
  type Feedback,
  type HeardAnswer,
  type TargetLine,
} from './speech-feedback.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.
// The lines are lines 1 to 10 of docs/risk-tests/test-2-voice-lines.md (not
// reviewed), used here as test data only.

const LINE_1: TargetLine = { spoken: 'Moi! Mä oon Alex.', written: 'Hei! Minä olen Alex.' }
const LINE_5: TargetLine = { spoken: 'Kiva tavata!', written: 'Hauska tavata!' }
const LINE_6: TargetLine = { spoken: 'Moi! Yks kahvi, kiitti.', written: 'Hei! Yksi kahvi, kiitos.' }
const LINE_8: TargetLine = { spoken: 'Paljonks se maksaa?', written: 'Paljonko se maksaa?' }
const LINE_10: TargetLine = { spoken: 'Joo, se on tosi hyvää.', written: 'Kyllä, se on todella hyvää.' }

function heard(text: string, words?: HeardAnswer['words']): HeardAnswer {
  return { status: 'heard', heard: text, words }
}

function say(target: TargetLine, text: string, words?: HeardAnswer['words']): Feedback {
  return classifySpeech(target, heard(text, words))
}

describe('the feedback classes', () => {
  it('[speak 10] the exact spoken line is clear, also with different capitals and punctuation', () => {
    expect(say(LINE_1, 'moi mä oon alex')).toEqual({ feedbackClass: 'clear' })
    expect(say(LINE_1, 'MOI, MÄ OON ALEX!!')).toEqual({ feedbackClass: 'clear' })
  })

  it('[speak 10] the written line counts as a match too (a service may write "mä oon" as "minä olen")', () => {
    expect(say(LINE_1, 'Hei minä olen Alex')).toEqual({ feedbackClass: 'clear' })
  })

  it('[speak 10] a mix of both registers word by word is clear when the lines have the same number of words', () => {
    expect(say(LINE_1, 'moi minä olen alex')).toEqual({ feedbackClass: 'clear' })
  })

  it('[speak 10] one extra word is still clear; more than the limit is try again', () => {
    expect(say(LINE_10, 'joo se on tosi hyvää kiitos')).toEqual({ feedbackClass: 'clear' })
    expect(say(LINE_10, 'joo no se on tosi hyvää kiitos')).toEqual({ feedbackClass: 'try_again' })
  })

  it('[speak 10] two or more words wrong is try again, with no hint', () => {
    expect(say(LINE_8, 'paljonks kello on')).toEqual({ feedbackClass: 'try_again' })
    expect(say(LINE_1, 'kuka sinä olet')).toEqual({ feedbackClass: 'try_again' })
  })

  it('[speak 10] nothing heard, or an empty transcript, is not heard', () => {
    expect(classifySpeech(LINE_1, { status: 'not_heard', heard: '' })).toEqual({ feedbackClass: 'not_heard' })
    expect(classifySpeech(LINE_1, heard('  ...  '))).toEqual({ feedbackClass: 'not_heard' })
    // A not heard status wins even over a transcript.
    expect(classifySpeech(LINE_1, { status: 'not_heard', heard: 'moi mä oon alex' })).toEqual({
      feedbackClass: 'not_heard',
    })
  })
})

describe('the hints', () => {
  it('[speak 10] a doubled letter missed (a long vowel or a double consonant) hints the double letter', () => {
    expect(say(LINE_1, 'moi mä on alex')).toEqual({
      feedbackClass: 'close',
      hint: { kind: 'double', letter: 'o' },
    })
    expect(say(LINE_6, 'moi yks kahvi kiiti')).toEqual({
      feedbackClass: 'close',
      hint: { kind: 'double', letter: 't' },
    })
  })

  it('[speak 10] a single letter doubled hints the single letter', () => {
    expect(say(LINE_5, 'kiva tavvata')).toEqual({
      feedbackClass: 'close',
      hint: { kind: 'single', letter: 'v' },
    })
  })

  it('[speak 10] ä said as a (and the other front and back vowel pairs) hints the vowel', () => {
    expect(say(LINE_1, 'moi ma oon alex')).toEqual({
      feedbackClass: 'close',
      hint: { kind: 'vowel', want: 'ä', heard: 'a' },
    })
    expect(letterHint('hyvää', 'huvää')).toEqual({ kind: 'vowel', want: 'y', heard: 'u' })
    expect(letterHint('kahvi', 'kehvi')).toBeNull()
  })

  it('[speak 10] one word missing hints that word, written as the approved line writes it', () => {
    expect(say(LINE_8, 'paljonks maksaa')).toEqual({
      feedbackClass: 'close',
      hint: { kind: 'missing', word: 'se' },
    })
  })

  it('[speak 10] one word off hints that word from the approved line, never the heard word', () => {
    const result = say(LINE_5, 'kiva tapata')
    expect(result).toEqual({ feedbackClass: 'close', hint: { kind: 'off', word: 'tavata' } })
    expect(JSON.stringify(result)).not.toContain('tapata')
    const far = say(LINE_1, 'moi mä oon pekka')
    expect(far).toEqual({ feedbackClass: 'close', hint: { kind: 'off', word: 'Alex' } })
    expect(JSON.stringify(far)).not.toContain('pekka')
  })

  it('[speak 10] a one word line that was not said at all is try again, not close', () => {
    const one: TargetLine = { spoken: 'Kiitti!', written: 'Kiitos!' }
    expect(classifySpeech(one, heard('moikka'))).toEqual({ feedbackClass: 'try_again' })
    expect(classifySpeech(one, heard('kiiti'))).toEqual({
      feedbackClass: 'close',
      hint: { kind: 'double', letter: 't' },
    })
  })
})

describe('word flags from the service', () => {
  it('[speak 10] a word flagged below the mispronunciation score turns clear into close, with the hint on that word', () => {
    const result = say(LINE_6, 'moi yks kahvi kiitti', [
      { word: 'moi', accuracy: 95, error: 'none' },
      { word: 'yks', accuracy: 90, error: 'none' },
      { word: 'kahvi', accuracy: 88, error: 'none' },
      { word: 'kiitti', accuracy: SPEECH_RULES.mispronunciationScore - 1, error: 'none' },
    ])
    expect(result).toEqual({ feedbackClass: 'close', hint: { kind: 'off', word: 'kiitti' } })
    // At the score itself the word is fine.
    expect(
      say(LINE_6, 'moi yks kahvi kiitti', [{ word: 'kiitti', accuracy: SPEECH_RULES.mispronunciationScore }]),
    ).toEqual({
      feedbackClass: 'clear',
    })
    expect(say(LINE_6, 'moi yks kahvi kiitti', [{ word: 'kahvi', error: 'mispronunciation' }])).toEqual({
      feedbackClass: 'close',
      hint: { kind: 'off', word: 'kahvi' },
    })
  })

  it('[speak 10] a flag never changes close or try again, and never names a word the learner did not say or the line does not have', () => {
    expect(say(LINE_1, 'moi mä on alex', [{ word: 'alex', accuracy: 10 }])).toEqual({
      feedbackClass: 'close',
      hint: { kind: 'double', letter: 'o' },
    })
    expect(say(LINE_8, 'paljonks kello on', [{ word: 'paljonks', accuracy: 10 }])).toEqual({
      feedbackClass: 'try_again',
    })
    // Said the written line: flags on spoken words that were not said are ignored.
    expect(
      say(LINE_1, 'hei minä olen alex', [{ word: 'oon', accuracy: 5, error: 'mispronunciation' }]),
    ).toEqual({
      feedbackClass: 'clear',
    })
    // A flagged word that is not in the approved line is ignored.
    expect(say(LINE_10, 'joo se on tosi hyvää kiitos', [{ word: 'kiitos', accuracy: 5 }])).toEqual({
      feedbackClass: 'clear',
    })
    // Omission and insertion flags are left to the transcript comparison.
    expect(say(LINE_1, 'moi mä oon alex', [{ word: 'oon', accuracy: 0, error: 'omission' }])).toEqual({
      feedbackClass: 'clear',
    })
  })
})

describe('the thresholds', () => {
  // That the numbers come from content/checks/speech-thresholds.json is
  // checked in scripts/eval/speech-golden.test.ts.
  it('[speak 10] the rules follow the numbers they are given', () => {
    const strict = { ...SPEECH_RULES, maxExtraWords: 0 }
    expect(classifySpeech(LINE_10, heard('joo se on tosi hyvää kiitos'), strict)).toEqual({
      feedbackClass: 'try_again',
    })
    const lenient = { ...SPEECH_RULES, maxWordErrorsForClose: 2 }
    expect(classifySpeech(LINE_8, heard('paljonks kello'), lenient).feedbackClass).toBe('close')
  })
})

describe('the status line message', () => {
  const cases: [Feedback, string, 'neutral' | 'gentle'][] = [
    [{ feedbackClass: 'clear' }, 'Yes, that was clear.', 'neutral'],
    [{ feedbackClass: 'close', hint: { kind: 'double', letter: 'k' } }, 'Close. Try the double k.', 'gentle'],
    [{ feedbackClass: 'close', hint: { kind: 'single', letter: 'k' } }, 'Close. Try a single k.', 'gentle'],
    [
      { feedbackClass: 'close', hint: { kind: 'vowel', want: 'ä', heard: 'a' } },
      'Close. Try ä instead of a.',
      'gentle',
    ],
    [
      { feedbackClass: 'close', hint: { kind: 'missing', word: 'oon' } },
      'Close. Try it again with oon.',
      'gentle',
    ],
    [
      { feedbackClass: 'close', hint: { kind: 'off', word: 'oon' } },
      'Close. Listen to oon once more, then try again.',
      'gentle',
    ],
    [{ feedbackClass: 'try_again' }, 'Listen to the line once more, then try again.', 'gentle'],
    [
      { feedbackClass: 'not_heard' },
      'That was too quiet to hear. Try again a little closer to the phone.',
      'gentle',
    ],
  ]

  it.each(cases)('[speak 7] %j reads "%s" in the %s tone', (feedback, text, tone) => {
    const message = feedbackMessage(feedback)
    expect(messageText(message)).toBe(text)
    expect(message.tone).toBe(tone)
  })

  it('[speak 7] Finnish words and letters are marked as Finnish, and no message holds a score, a count or red words', () => {
    for (const [feedback] of cases) {
      const message = feedbackMessage(feedback)
      for (const part of message.parts) {
        if (typeof part === 'string') expect(part).not.toMatch(/\d|%|score|wrong|incorrect|mistake|error/i)
      }
    }
    const word = feedbackMessage({ feedbackClass: 'close', hint: { kind: 'missing', word: 'oon' } })
    expect(word.parts).toContainEqual({ fi: 'oon' })
  })
})
