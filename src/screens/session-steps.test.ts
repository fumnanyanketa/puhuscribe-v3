import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { describe, expect, it } from 'vitest'
import { SessionFrame } from '../components/SessionFrame.tsx'
import type { ReadySession } from '../lib/session-types.ts'
import { SessionFlow } from './SessionFlow.tsx'
import { SESSION_STEPS, after, resumeAt, type SessionStep } from './session-steps.ts'
import type { StepScreenProps } from './step-screen.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md that each test protects.
// The steps come from one list; the finish screen follows the last one.

const session: ReadySession = {
  state: 'ready',
  session: { id: '00000000-0000-4000-8000-000000000001', step: null },
  unit: { title: 'Unit', canDo: 'Can do.' },
  dialogue: { title: 'Dialogue' },
  lines: [
    {
      id: 1,
      speaker: 'A',
      gloss: 'Hi.',
      spokenAudio: '/audio/a.mp3',
      writtenAudio: '/audio/b.mp3',
      spoken: [{ text: 'Moi', after: '!' }],
      written: [{ text: 'Hei', after: '!' }],
    },
  ],
}

function SayItProbe({ frame }: StepScreenProps) {
  return createElement(SessionFrame, {
    step: frame.step,
    steps: frame.steps,
    leaveHref: '/',
    actions: createElement('span', null, 'probe actions'),
    children: createElement('h1', null, 'Say it probe'),
  })
}

const withSayIt: readonly SessionStep[] = [
  ...SESSION_STEPS,
  // Job 10 adds Say it here. Its id is not recordable yet, so the probe borrows one.
  { id: 'understand', name: 'Say it', Screen: SayItProbe },
]

function render(steps: readonly SessionStep[], position: ReturnType<typeof resumeAt>) {
  return renderToStaticMarkup(
    createElement(SessionFlow, { steps, session, position, onStepDone: () => Promise.resolve(true) }),
  )
}

describe('the session steps', () => {
  it('[session 8] are Hear it, then Understand it, in one list', () => {
    expect(SESSION_STEPS.map((step) => [step.id, step.name])).toEqual([
      ['hear', 'Hear it'],
      ['understand', 'Understand it'],
    ])
  })

  it('[session 8] the top bar reads "Hear it, step 1 of 2" and "Understand it, step 2 of 2"', () => {
    expect(render(SESSION_STEPS, { kind: 'step', index: 0 })).toContain('Hear it, step 1 of 2')
    expect(render(SESSION_STEPS, { kind: 'step', index: 1 })).toContain('Understand it, step 2 of 2')
  })

  it('[session 8] [session 14] the finish screen follows the last step', () => {
    expect(after(SESSION_STEPS, 0)).toEqual({ kind: 'step', index: 1 })
    expect(after(SESSION_STEPS, 1)).toEqual({ kind: 'finish' })
    const finish = render(SESSION_STEPS, { kind: 'finish' })
    expect(finish).toContain('Now you can say this.')
    expect(finish).toContain('Session finished')
  })

  it('[session 8] a step added to the list renders between Understand it and the finish screen', () => {
    expect(after(withSayIt, 1)).toEqual({ kind: 'step', index: 2 })
    const sayIt = render(withSayIt, after(withSayIt, 1))
    expect(sayIt).toContain('Say it probe')
    expect(sayIt).toContain('Say it, step 3 of 3')
    expect(after(withSayIt, 2)).toEqual({ kind: 'finish' })
    expect(render(SESSION_STEPS, { kind: 'step', index: 1 })).toContain('Understand it, step 2 of 2')
  })

  it('[session 18] resumes at Hear it with no step, Understand it after hear, and the finish screen after understand', () => {
    expect(resumeAt(SESSION_STEPS, null)).toEqual({ kind: 'step', index: 0 })
    expect(resumeAt(SESSION_STEPS, 'hear')).toEqual({ kind: 'step', index: 1 })
    expect(resumeAt(SESSION_STEPS, 'understand')).toEqual({ kind: 'finish' })
  })

  it('[session 8] SessionFrame keeps its default steps when no list is given (job 5)', () => {
    const markup = renderToStaticMarkup(
      createElement(SessionFrame, { step: 'Hear it', leaveHref: '/', actions: null, children: null }),
    )
    expect(markup).toContain('Hear it, step 1 of 4')
  })
})
