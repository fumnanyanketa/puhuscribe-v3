import { describe, expect, it } from 'vitest'
import {
  SPEECH_RULES,
  betterCheck,
  classifySpeech,
  classifyWritten,
  feedbackMessage,
  letterHint,
  messageText,
  needsWrittenCheck,
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

// The written form judged against the written form (fast route bug fix written-form-feedback,
// 5 November 2026). Statements, from factory/jobs/written-form-feedback/build.md:
// 1. Saying the written form well is clear.
// 2. Saying the written form with one badly said word hints at that written word.
// 3. Saying the spoken form is judged as before.
// 4. The written line is checked a second time only when the first try was heard, was not clear,
//    and the written line has other words.
// The answers below have the shape the speech service gives when it is sent a reference text: its
// transcript leans towards that reference, and words that do not fit it get a low accuracy.

const AINO: TargetLine = { spoken: 'Hei! Mä oon Aino.', written: 'Hei! Minä olen Aino.' }

/** The written form said well, scored against the spoken line (what the live site saw). */
const WRITTEN_AGAINST_SPOKEN = heard('hei mä oon aino', [
  { word: 'hei', accuracy: 96, error: 'none' },
  { word: 'mä', accuracy: 22, error: 'mispronunciation' },
  { word: 'oon', accuracy: 35, error: 'mispronunciation' },
  { word: 'aino', accuracy: 94, error: 'none' },
])

describe('the written form is judged against the written form', () => {
  it('[written-form-feedback 1] the written form said well is clear once checked against the written line', () => {
    // The first check, against the spoken line, is what gave "Listen to Mä" on the live site.
    const first = classifySpeech(AINO, WRITTEN_AGAINST_SPOKEN)
    expect(messageText(feedbackMessage(first))).toBe('Close. Listen to Mä once more, then try again.')
    expect(needsWrittenCheck(AINO, first)).toBe(true)
    const answer = heard('hei minä olen aino', [
      { word: 'hei', accuracy: 97, error: 'none' },
      { word: 'minä', accuracy: 93, error: 'none' },
      { word: 'olen', accuracy: 95, error: 'none' },
      { word: 'aino', accuracy: 96, error: 'none' },
    ])
    const second = classifyWritten(AINO, answer)
    expect(second).toEqual({ feedbackClass: 'clear' })
    expect(
      betterCheck({ answer: WRITTEN_AGAINST_SPOKEN, feedback: first }, { answer, feedback: second }).feedback,
    ).toEqual({ feedbackClass: 'clear' })
  })

  it('[written-form-feedback 2] the written form with a badly said word hints at that written word', () => {
    const first = classifySpeech(AINO, WRITTEN_AGAINST_SPOKEN)
    const answer = heard('hei minä olen aino', [
      { word: 'hei', accuracy: 96, error: 'none' },
      { word: 'minä', accuracy: 90, error: 'none' },
      { word: 'olen', accuracy: 38, error: 'mispronunciation' },
      { word: 'aino', accuracy: 95, error: 'none' },
    ])
    const second = classifyWritten(AINO, answer)
    expect(second).toEqual({ feedbackClass: 'close', hint: { kind: 'off', word: 'olen' } })
    const chosen = betterCheck(
      { answer: WRITTEN_AGAINST_SPOKEN, feedback: first },
      { answer, feedback: second },
    )
    expect(chosen.feedback).toEqual({ feedbackClass: 'close', hint: { kind: 'off', word: 'olen' } })
    expect(chosen.answer).toBe(answer)
  })

  it('[written-form-feedback 2] a flagged written word hints at that word when the transcript is the written line', () => {
    // Before the fix only the spoken line's words could be hinted, so this was clear.
    expect(
      say(AINO, 'hei minä olen aino', [
        { word: 'minä', accuracy: 90, error: 'none' },
        { word: 'olen', accuracy: 30, error: 'mispronunciation' },
      ]),
    ).toEqual({ feedbackClass: 'close', hint: { kind: 'off', word: 'olen' } })
  })

  it('[written-form-feedback 3] the spoken form said well is clear with no second check', () => {
    const first = say(AINO, 'hei mä oon aino', [
      { word: 'hei', accuracy: 96, error: 'none' },
      { word: 'mä', accuracy: 94, error: 'none' },
      { word: 'oon', accuracy: 92, error: 'none' },
      { word: 'aino', accuracy: 95, error: 'none' },
    ])
    expect(first).toEqual({ feedbackClass: 'clear' })
    expect(needsWrittenCheck(AINO, first)).toBe(false)
  })

  it('[written-form-feedback 3] the spoken form with a badly said word keeps its spoken hint after the written check', () => {
    const spokenAnswer = heard('hei mä oon aino', [
      { word: 'hei', accuracy: 96, error: 'none' },
      { word: 'mä', accuracy: 92, error: 'none' },
      { word: 'oon', accuracy: 41, error: 'mispronunciation' },
      { word: 'aino', accuracy: 95, error: 'none' },
    ])
    const first = classifySpeech(AINO, spokenAnswer)
    expect(first).toEqual({ feedbackClass: 'close', hint: { kind: 'off', word: 'oon' } })
    // Against the written line the service leans the transcript to the written words and scores them low.
    const leaned = heard('hei minä olen aino', [
      { word: 'hei', accuracy: 96, error: 'none' },
      { word: 'minä', accuracy: 24, error: 'mispronunciation' },
      { word: 'olen', accuracy: 20, error: 'mispronunciation' },
      { word: 'aino', accuracy: 95, error: 'none' },
    ])
    expect(
      betterCheck(
        { answer: spokenAnswer, feedback: first },
        { answer: leaned, feedback: classifyWritten(AINO, leaned) },
      ).feedback,
    ).toEqual(first)
    // Or it writes what it heard and marks the written words as left out. Judged against the
    // written line only, that is try again, so the spoken hint stays.
    const missed = heard('hei mä oon aino', [
      { word: 'hei', accuracy: 96, error: 'none' },
      { word: 'mä', error: 'insertion' },
      { word: 'oon', error: 'insertion' },
      { word: 'minä', accuracy: 0, error: 'omission' },
      { word: 'olen', accuracy: 0, error: 'omission' },
      { word: 'aino', accuracy: 95, error: 'none' },
    ])
    const writtenOnly = classifyWritten(AINO, missed)
    expect(writtenOnly).toEqual({ feedbackClass: 'try_again' })
    expect(
      betterCheck({ answer: spokenAnswer, feedback: first }, { answer: missed, feedback: writtenOnly })
        .feedback,
    ).toEqual(first)
  })

  it('[written-form-feedback 4] only a heard try that is not clear, on a line with other written words, is checked again', () => {
    expect(needsWrittenCheck(AINO, { feedbackClass: 'clear' })).toBe(false)
    expect(needsWrittenCheck(AINO, { feedbackClass: 'not_heard' })).toBe(false)
    expect(needsWrittenCheck(AINO, { feedbackClass: 'try_again' })).toBe(true)
    expect(needsWrittenCheck(AINO, { feedbackClass: 'close', hint: { kind: 'off', word: 'Mä' } })).toBe(true)
    // The same words in both registers (only punctuation or capitals differ): nothing to check again.
    const same: TargetLine = { spoken: 'Kiitos!', written: 'kiitos.' }
    expect(needsWrittenCheck(same, { feedbackClass: 'try_again' })).toBe(false)
  })

  it('[written-form-feedback 4] on a tie the answer the service scored higher wins, and the first one when equal', () => {
    const low = heard('hei mä oon aino', [{ word: 'mä', accuracy: 30 }])
    const high = heard('hei minä olen aino', [{ word: 'minä', accuracy: 80 }])
    const tie: Feedback = { feedbackClass: 'try_again' }
    expect(betterCheck({ answer: low, feedback: tie }, { answer: high, feedback: tie }).answer).toBe(high)
    expect(betterCheck({ answer: high, feedback: tie }, { answer: low, feedback: tie }).answer).toBe(high)
    const plain = heard('hei')
    expect(
      betterCheck({ answer: plain, feedback: tie }, { answer: heard('moi'), feedback: tie }).answer,
    ).toBe(plain)
    // A better class always wins, whatever the scores.
    expect(
      betterCheck({ answer: high, feedback: tie }, { answer: low, feedback: { feedbackClass: 'clear' } })
        .answer,
    ).toBe(low)
  })
})
