import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { describe, expect, it } from 'vitest'
import type { ReviewItem } from '../lib/review-types.ts'
import type { ReadySession } from '../lib/session-types.ts'
import { ANSWER_METHODS, type AnswerMethod, type AnswerMethodProps } from './answer-methods.ts'
import { KeepIt } from './KeepIt.tsx'
import { ReviewItemView } from './ReviewItemView.tsx'
import { SessionFlow } from './SessionFlow.tsx'
import { KEEP_IT_STEP, SESSION_STEPS, after, resumeAt, stepsFor } from './session-steps.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/9-daily-review/spec.md that each test protects.
// Keep it in the step list, the review item and its answer methods.

const item: ReviewItem = {
  formId: 3,
  speaker: 'Alex',
  gloss: 'Hi! I am Alex.',
  register: 'spoken',
  audio: '/audio/unit-test/1-puhe.mp3',
  words: [{ text: 'Moi', after: '!' }, { text: 'Mä' }, { gap: true }, { text: 'Alex', after: '.' }],
}

const session: ReadySession = {
  state: 'ready',
  session: { id: '00000000-0000-4000-8000-000000000001', step: 'understand' },
  unit: { title: 'Unit', canDo: 'Can do.' },
  dialogue: { title: 'Dialogue' },
  lines: [
    {
      id: 1,
      speaker: 'Alex',
      gloss: 'Hi! I am Alex.',
      spokenAudio: '/audio/a.mp3',
      writtenAudio: '/audio/b.mp3',
      spoken: [{ text: 'Moi', after: '!' }],
      written: [{ text: 'Hei', after: '!' }],
    },
  ],
}

const noop = () => undefined

function renderItem(methods?: readonly AnswerMethod[]) {
  return renderToStaticMarkup(
    createElement(ReviewItemView, {
      item,
      formBase: 'item',
      disabled: false,
      onReady: noop,
      onAnswer: noop,
      ...(methods ? { methods } : {}),
    }),
  )
}

function answerArea(markup: string): string {
  const start = markup.indexOf('data-answer-area')
  expect(start).toBeGreaterThan(-1)
  return markup.slice(start)
}

describe('Keep it in the step list', () => {
  it('[review 6] with words to review, Keep it comes after every step of the list, as step 3 of 3', () => {
    expect(stepsFor(true).map((step) => step.name)).toEqual(['Hear it', 'Understand it', 'Keep it'])
    expect(stepsFor(true).at(-1)).toBe(KEEP_IT_STEP)
    expect(KEEP_IT_STEP.id).toBe('keep')
    const steps = stepsFor(true)
    const markup = renderToStaticMarkup(
      createElement(SessionFlow, {
        steps,
        session,
        position: { kind: 'step', index: 2 },
        onStepDone: () => Promise.resolve(true),
        review: [item],
      }),
    )
    expect(markup).toContain('Keep it, step 3 of 3')
    expect(after(steps, 2)).toEqual({ kind: 'finish' })
  })

  it("[review 6] without words to review, the session is exactly job 8's: step 1 of 2", () => {
    expect(stepsFor(false)).toBe(SESSION_STEPS)
    const markup = renderToStaticMarkup(
      createElement(SessionFlow, {
        steps: stepsFor(false),
        session: { ...session, session: { ...session.session, step: null } },
        position: { kind: 'step', index: 0 },
        onStepDone: () => Promise.resolve(true),
      }),
    )
    expect(markup).toContain('Hear it, step 1 of 2')
  })

  it('[review 6] [review 14] "Continue" after Understand it resumes at Keep it; after keep, the finish screen', () => {
    expect(resumeAt(stepsFor(true), 'understand')).toEqual({ kind: 'step', index: 2 })
    expect(resumeAt(stepsFor(true), 'keep')).toEqual({ kind: 'finish' })
    expect(resumeAt(stepsFor(false), 'keep')).toEqual({ kind: 'finish' })
  })

  it("[review 6] job 10's Say it, added to the list, sits before Keep it", () => {
    // A copy of the list with a step after Understand it, as job 10 adds Say it.
    const sayIt = { ...SESSION_STEPS[1], id: 'say' as const, name: 'Say it' as const }
    const withSayIt = [...SESSION_STEPS, sayIt, KEEP_IT_STEP]
    expect(withSayIt.map((step) => step.name)).toEqual(['Hear it', 'Understand it', 'Say it', 'Keep it'])
    expect(resumeAt(withSayIt, 'say')).toEqual({ kind: 'step', index: 3 })
  })
})

describe('the review item', () => {
  it('[review 8] shows the speaker, the line with a gap read as "missing word", its meaning and one play control', () => {
    const markup = renderItem()
    expect(markup).toContain('Alex')
    expect(markup).toContain('Hi! I am Alex.')
    expect(markup).toContain('missing word')
    expect(markup).toContain('lang="fi"')
    expect(markup).toContain('Play the spoken line')
    expect(markup).not.toContain('Play the written line')
    expect(markup).toContain('Spoken')
    // No word cards before answering.
    expect(markup).not.toContain('aria-haspopup')
  })

  it('[review 9] the field is labelled, Finnish, with phone typing aids off, at most 100 characters, and ä and ö buttons', () => {
    const markup = renderItem()
    expect(markup).toContain('Type the missing word')
    for (const attribute of [
      'lang="fi"',
      'autoCapitalize="off"',
      'autoCorrect="off"',
      'spellcheck="false"',
      'autoComplete="off"',
      'enterKeyHint="done"',
      'maxLength="100"',
    ]) {
      expect(markup.toLowerCase()).toContain(attribute.toLowerCase())
    }
    expect(markup).toContain('aria-label="Type ä"')
    expect(markup).toContain('aria-label="Type ö"')
  })

  it('[review 15] the answer methods come from one list: today only typing', () => {
    expect(ANSWER_METHODS.map((method) => method.kind)).toEqual(['typed'])
  })

  it("[review 15] a second method added to the list renders in the item's answer area", () => {
    function SpokenProbe({ formId }: AnswerMethodProps) {
      return createElement('p', { id: formId }, 'Spoken answer probe')
    }
    // Job 10 adds a "spoken" kind; the probe borrows the typed kind's type.
    const withProbe: readonly AnswerMethod[] = [
      ...ANSWER_METHODS,
      { kind: 'spoken' as 'typed', Answer: SpokenProbe },
    ]
    const markup = renderItem(withProbe)
    const area = answerArea(markup)
    expect(area).toContain('Spoken answer probe')
    expect(area).toContain('Type the missing word')
    expect(area.indexOf('Type the missing word')).toBeLessThan(area.indexOf('Spoken answer probe'))
    expect(renderItem()).not.toContain('Spoken answer probe')
  })
})

describe('the Keep it screen', () => {
  it('[review 8] [review 9] the first item shows its place, the instruction, Check and "I don\'t remember"', () => {
    const markup = renderToStaticMarkup(
      createElement(KeepIt, {
        sessionId: session.session.id,
        items: [item, { ...item, formId: 4 }],
        frame: { step: 'Keep it', steps: ['Hear it', 'Understand it', 'Keep it'] },
        onDone: () => Promise.resolve(true),
      }),
    )
    expect(markup).toContain('Word 1 of 2.')
    expect(markup).toContain('Type the missing word.')
    expect(markup).toContain('>Check<')
    expect(markup).toContain('I don&#x27;t remember')
    // Check is unavailable while the field is empty.
    expect(markup).toMatch(
      /<button[^>]*disabled=""[^>]*form="[^"]+"[^>]*>|<button[^>]*form="[^"]+"[^>]*disabled=""/,
    )
    expect(markup).not.toMatch(/score|points|streak|wrong|incorrect/i)
  })
})
