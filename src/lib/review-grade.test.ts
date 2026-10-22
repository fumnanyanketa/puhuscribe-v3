import { describe, expect, it } from 'vitest'
import { Rating } from './fsrs/types.ts'
import { RATING_FOR, gradeReview } from './review-grade.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/9-daily-review/spec.md that each test protects.
// The grading wrapper: v2's grader, against both shapes, the better result counts.

const minä = { spoken: 'mä', written: 'minä' }
const olen = { spoken: 'oon', written: 'olen' }
const long = { spoken: 'Helsingis', written: 'Helsingissä' }
const typed = (text: string) => ({ kind: 'typed' as const, text })

describe('gradeReview', () => {
  it('[review 10] the exact spoken shape is right', () => {
    expect(gradeReview(typed('mä'), minä)).toEqual({ result: 'correct', rating: Rating.Good })
  })

  it('[review 10] the exact written shape is right too', () => {
    expect(gradeReview(typed('minä'), minä)).toEqual({ result: 'correct', rating: Rating.Good })
    expect(gradeReview(typed('olen'), olen)).toEqual({ result: 'correct', rating: Rating.Good })
  })

  it('[review 10] capital letters do not matter', () => {
    expect(gradeReview(typed('MINÄ'), minä).result).toBe('correct')
    expect(gradeReview(typed('Oon'), olen).result).toBe('correct')
  })

  it('[review 10] a missing ä is close', () => {
    expect(gradeReview(typed('mina'), minä)).toEqual({ result: 'close', rating: Rating.Hard })
  })

  it('[review 10] one slip in a long word is close', () => {
    expect(gradeReview(typed('Helsingisä'), long)).toEqual({ result: 'close', rating: Rating.Hard })
    expect(gradeReview(typed('Helsinkis'), long)).toEqual({ result: 'close', rating: Rating.Hard })
  })

  it('[review 10] another word is wrong', () => {
    expect(gradeReview(typed('sinä'), olen)).toEqual({ result: 'wrong', rating: Rating.Again })
    expect(gradeReview(typed('kotoisin'), minä)).toEqual({ result: 'wrong', rating: Rating.Again })
  })

  it('[review 10] an empty answer ("I don\'t remember") is wrong', () => {
    expect(gradeReview(typed(''), minä)).toEqual({ result: 'wrong', rating: Rating.Again })
    expect(gradeReview(typed('   '), minä)).toEqual({ result: 'wrong', rating: Rating.Again })
  })

  it('[review 10] extra spaces and punctuation do not matter', () => {
    expect(gradeReview(typed('  minä  '), minä).result).toBe('correct')
    expect(gradeReview(typed('oon!'), olen).result).toBe('correct')
    expect(gradeReview(typed('"mä."'), minä).result).toBe('correct')
  })

  it('[review 10] the better of the two shapes counts: close to one beats wrong against the other', () => {
    // "olem" is one slip from "olen" (close) and far from "oon".
    expect(gradeReview(typed('olem'), olen).result).toBe('close')
    // "on" is one slip from "oon" (close) and far from "olen".
    expect(gradeReview(typed('on'), olen).result).toBe('close')
  })

  it('[review 10] the rating follows from the result only: Good, Hard, Again', () => {
    expect(RATING_FOR).toEqual({ correct: Rating.Good, close: Rating.Hard, wrong: Rating.Again })
  })
})
