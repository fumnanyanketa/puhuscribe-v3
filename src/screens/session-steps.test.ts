import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { describe, expect, it } from 'vitest'
import { SessionFrame } from '../components/SessionFrame.tsx'
import type { ReadySession } from '../lib/session-types.ts'
import { SessionFlow } from './SessionFlow.tsx'
import { SESSION_STEPS, after, resumeAt, type SessionStep } from './session-steps.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md that each test protects ([speak N]:
// factory/jobs/10-speaking-feedback/spec.md). Job 10's statement 5 adds Say
// it to the list and updated the tests here that name the step count or the
// resume point, keeping their labels.
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

function render(steps: readonly SessionStep[], position: ReturnType<typeof resumeAt>) {
  return renderToStaticMarkup(
    createElement(SessionFlow, { steps, session, position, onStepDone: () => Promise.resolve(true) }),
  )
}

describe('the session steps', () => {
  it('[session 8] [speak 5] are Hear it, then Understand it, then Say it, in one list', () => {
    expect(SESSION_STEPS.map((step) => [step.id, step.name])).toEqual([
      ['hear', 'Hear it'],
      ['understand', 'Understand it'],
      ['say', 'Say it'],
    ])
  })

  it('[session 8] [speak 5] the top bar reads "Hear it, step 1 of 3", "Understand it, step 2 of 3" and "Say it, step 3 of 3"', () => {
    expect(render(SESSION_STEPS, { kind: 'step', index: 0 })).toContain('Hear it, step 1 of 3')
    expect(render(SESSION_STEPS, { kind: 'step', index: 1 })).toContain('Understand it, step 2 of 3')
    expect(render(SESSION_STEPS, { kind: 'step', index: 2 })).toContain('Say it, step 3 of 3')
  })

  it('[session 8] [session 14] [speak 5] the finish screen follows the last step', () => {
    expect(after(SESSION_STEPS, 0)).toEqual({ kind: 'step', index: 1 })
    expect(after(SESSION_STEPS, 1)).toEqual({ kind: 'step', index: 2 })
    expect(after(SESSION_STEPS, 2)).toEqual({ kind: 'finish' })
    const finish = render(SESSION_STEPS, { kind: 'finish' })
    expect(finish).toContain('Now you can say this.')
    expect(finish).toContain('Session finished')
  })

  it('[session 8] [speak 5] Say it renders between Understand it and the finish screen', () => {
    const sayIt = render(SESSION_STEPS, after(SESSION_STEPS, 1))
    expect(sayIt).toContain('<h1')
    expect(sayIt).toContain('Say it, step 3 of 3')
    expect(sayIt).toContain('Loading speaking feedback.')
    expect(after(SESSION_STEPS, 2)).toEqual({ kind: 'finish' })
  })

  it('[session 18] [speak 5] resumes at Hear it with no step, Understand it after hear, Say it after understand, and the finish screen after say', () => {
    expect(resumeAt(SESSION_STEPS, null)).toEqual({ kind: 'step', index: 0 })
    expect(resumeAt(SESSION_STEPS, 'hear')).toEqual({ kind: 'step', index: 1 })
    expect(resumeAt(SESSION_STEPS, 'understand')).toEqual({ kind: 'step', index: 2 })
    expect(resumeAt(SESSION_STEPS, 'say')).toEqual({ kind: 'finish' })
  })

  it('[session 8] SessionFrame keeps its default steps when no list is given (job 5)', () => {
    const markup = renderToStaticMarkup(
      createElement(SessionFrame, { step: 'Hear it', leaveHref: '/', actions: null, children: null }),
    )
    expect(markup).toContain('Hear it, step 1 of 4')
  })
})
