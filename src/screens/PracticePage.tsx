import { useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import { Button } from '../components/Button.tsx'
import { PlayControl } from '../components/PlayControl.tsx'
import { SessionFrame, type LoopStep } from '../components/SessionFrame.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { callApi, isRecord } from '../lib/api.ts'
import { PATHS } from '../lib/app-paths.ts'
import type { PracticeAnswer } from '../lib/practice-types.ts'
import { pickFinishLine } from '../lib/session-rules.ts'
import type { ReadySession } from '../lib/session-types.ts'
import { HearIt } from './HearIt.tsx'
import { KeepIt } from './KeepIt.tsx'
import { LINE_AUDIO } from './LineCard.tsx'
import { PatternsProvider } from './PatternsProvider.tsx'
import { SayIt } from './SayIt.tsx'
import type { StepScreenProps } from './step-screen.ts'
import { UnderstandIt } from './UnderstandIt.tsx'
import styles from './Screens.module.css'
import own from './PracticePage.module.css'

// A practice replay of a finished lesson, at /session?practice=<dialogue id> (owner's fast route
// go-back, 3 November 2026). The learner picked the lesson from a done stop on the road. It goes through
// Hear it, say it, Understand it, the Recap and Keep it for that dialogue, with the same screens as a
// lesson, then a finish screen that says it was practice.
//
// It reads the lesson through GET /api/practice?dialogue=<id> and writes nothing of its own: no step is
// stored, the lesson is not finished again, the road does not move and the review schedule does not
// change. Keep it's answers are checked in the browser (KeepIt's practiceAnswers). The only requests that
// can store something are the speaking feedback checks the learner asks for, which the owner allowed.

const LOADING = 'Loading the lesson.'
const NOT_LOADED = 'This lesson could not be loaded. Check your internet connection, then try again.'
const NOT_FOUND = 'This lesson cannot be practised. Only a lesson you have finished can be played again.'
export const PRACTICE_TITLE = 'Practice finished'
export const PRACTICE_NOTE =
  'This was practice. Your road, your progress and your review words have not changed.'

type Load =
  | { kind: 'loading' }
  | { kind: 'problem'; text: string; retry: boolean }
  | { kind: 'ready'; answer: PracticeAnswer }

function isPractice(body: unknown): body is PracticeAnswer {
  return (
    isRecord(body) &&
    isRecord(body.session) &&
    body.session.state === 'ready' &&
    Array.isArray(body.session.lines) &&
    Array.isArray(body.keep)
  )
}

async function loadPractice(dialogueId: number): Promise<Load | 'signed_out'> {
  const answer = await callApi(`/api/practice?dialogue=${String(dialogueId)}`, 'GET')
  if (!answer) return { kind: 'problem', text: NOT_LOADED, retry: true }
  if (answer.status === 401) return 'signed_out'
  if (answer.status === 404 || answer.status === 400)
    return { kind: 'problem', text: NOT_FOUND, retry: false }
  if (answer.status === 200 && isPractice(answer.body)) return { kind: 'ready', answer: answer.body }
  return { kind: 'problem', text: NOT_LOADED, retry: true }
}

interface PracticeStep {
  name: LoopStep
  Screen: (props: StepScreenProps) => ReactNode
}

/** The finish screen of a practice replay: plain words that it was practice, and one way back. */
function PracticeFinish({ session, steps }: { session: ReadySession; steps: readonly LoopStep[] }) {
  const line = pickFinishLine(session.lines)
  const lastStep = steps[steps.length - 1] ?? 'Hear it, say it'
  const actions = (
    <Button
      block
      onClick={() => {
        window.location.assign(PATHS.home)
      }}
    >
      Back to the road
    </Button>
  )
  return (
    <SessionFrame step={lastStep} steps={steps} finished leaveHref={PATHS.home} actions={actions}>
      <main className={styles.finishMain}>
        <div className={styles.orb} aria-hidden="true">
          <svg viewBox="0 0 24 24" focusable="false">
            <path d="M5 12.5l4.5 4.5L19 7.5" />
          </svg>
        </div>
        <h1 className={styles.finishTitle}>{PRACTICE_TITLE}</h1>
        <p className={own.note}>{PRACTICE_NOTE}</p>
        {line && (
          <div className={styles.finishLine} data-line-id={line.id}>
            <div className={styles.finishRow}>
              <p className={styles.finishSpoken} lang="fi">
                {line.spoken.map((w) => `${w.before ?? ''}${w.text}${w.after ?? ''}`).join(' ')}
              </p>
              <PlayControl src={line.spokenAudio} what={LINE_AUDIO.spoken} size="small" />
            </div>
            <div className={styles.finishRow}>
              <p className={styles.finishWritten} lang="fi">
                {line.written.map((w) => `${w.before ?? ''}${w.text}${w.after ?? ''}`).join(' ')}
              </p>
              <PlayControl src={line.writtenAudio} what={LINE_AUDIO.written} size="small" tone="written" />
            </div>
            <p className={styles.finishGloss}>{line.gloss}</p>
          </div>
        )}
      </main>
    </SessionFrame>
  )
}

function PracticeFlow({ answer }: { answer: PracticeAnswer }) {
  const { session, keep } = answer
  const [at, setAt] = useState(0)
  const answers = useMemo(() => new Map(keep.map((k) => [k.item.formId, k.answer])), [keep])
  const items = useMemo(() => keep.map((k) => k.item), [keep])
  const steps = useMemo(() => {
    const list: PracticeStep[] = [
      { name: 'Hear it, say it', Screen: HearIt },
      { name: 'Understand it', Screen: UnderstandIt },
      { name: 'Recap', Screen: SayIt },
    ]
    if (items.length > 0) {
      list.push({
        name: 'Keep it',
        Screen: ({ frame, onDone }: StepScreenProps) => (
          <KeepIt
            sessionId={session.session.id}
            items={items}
            frame={frame}
            onDone={onDone}
            practiceAnswers={answers}
          />
        ),
      })
    }
    return list
  }, [answers, items, session.session.id])
  const names = steps.map((step) => step.name)
  const current = steps.at(at)
  return (
    <PatternsProvider sessionId={session.session.id}>
      {current ? (
        <current.Screen
          key={current.name}
          session={session}
          frame={{ step: current.name, steps: names, index: at }}
          practice
          onDone={() => {
            // Practice stores nothing: the next step, or the finish screen.
            setAt(at + 1)
            return Promise.resolve(true)
          }}
        />
      ) : (
        <PracticeFinish session={session} steps={names} />
      )}
    </PatternsProvider>
  )
}

export function PracticePage({ dialogueId }: { dialogueId: number }) {
  const [load, setLoad] = useState<Load>({ kind: 'loading' })
  const status = useRef<HTMLParagraphElement>(null)
  const firstLoad = useRef<Promise<Load | 'signed_out'> | null>(null)

  function show(next: Load | 'signed_out') {
    if (next === 'signed_out') {
      window.location.replace(PATHS.home)
      return
    }
    setLoad(next)
  }

  useEffect(() => {
    let active = true
    firstLoad.current ??= loadPractice(dialogueId)
    void firstLoad.current.then((next) => {
      if (active) show(next)
    })
    return () => {
      active = false
    }
  }, [dialogueId])

  if (load.kind === 'ready') return <PracticeFlow answer={load.answer} />

  return (
    <main className={styles.plainPage}>
      <h1 className={styles.title}>Practice</h1>
      <StatusLine ref={status} tone={load.kind === 'problem' ? 'problem' : 'neutral'}>
        {load.kind === 'problem' ? load.text : LOADING}
      </StatusLine>
      {load.kind === 'problem' && load.retry && (
        <Button
          variant="secondary"
          block
          onClick={() => {
            status.current?.focus()
            setLoad({ kind: 'loading' })
            void loadPractice(dialogueId).then(show)
          }}
        >
          Try again
        </Button>
      )}
      {load.kind === 'problem' && (
        <Button
          variant="quiet"
          onClick={() => {
            window.location.assign(PATHS.home)
          }}
        >
          Back to the road
        </Button>
      )}
    </main>
  )
}
