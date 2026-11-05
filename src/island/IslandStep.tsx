import { useCallback, useEffect, useId, useRef, useState, type MouseEvent } from 'react'
import { Button } from '../components/Button.tsx'
import { RecordControl, type RecordState } from '../components/RecordControl.tsx'
import { SessionFrame, type LoopStep } from '../components/SessionFrame.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { TextField } from '../components/TextField.tsx'
import {
  NAME_MAX,
  choicesOf,
  cleanName,
  fillLine,
  type IslandEntry,
  type IslandStop,
} from '../lib/islands.ts'
import {
  RecorderFailed,
  recordingSupported,
  startRecording,
  type RecorderHandle,
  type Recording,
} from '../lib/recorder.ts'
import { MIN_RECORDING_MS } from '../lib/speech-types.ts'
import { useSteadyPress } from '../lib/use-steady-press.ts'
import screens from '../screens/Screens.module.css'
import voice from '../screens/Voice.module.css'
import { IslandLine } from './IslandLine.tsx'
import styles from './Island.module.css'
import { louderForPlayback } from '../lib/wav.ts'

// The "Use it" island step (language islands, fast route of 3 November 2026), as in the approved
// mockup. At the end of a stop's last lesson the learner fills the gaps of the stop's approved
// pattern (the first name typed at stop 1 only, every other gap a choice from the checked list), hears
// the line in spoken and written Finnish with its meaning, says it back with Say it's recorder, and
// adds it to their island. The recording stays in this page's memory and goes when the learner moves
// on: nothing is sent anywhere. The same screen changes a line from the island card on the road.

export const FILL_SUB_ONE = 'Fill the gap. This becomes yours.'
export const FILL_SUB_MANY = 'Fill the gaps. This becomes yours.'
export const SAY_TITLE = 'Say it as yours'
export const NAME_NOTE = 'The voice leaves out your name. You say that part.'
export const NOT_SAVED_LINE = 'Your line was not saved. Check your internet connection, then try again.'
export const NAME_HELP = `Letters only, at most ${String(NAME_MAX)}.`
const RECORD_HINTS = { ready: 'Tap and say your line' }
const MIC_OFF =
  'Microphone access is off. You can turn it on in your browser settings, or add the line without recording.'
const SHOWN_FIRST = 6

type Phase = 'fill' | 'say'

interface IslandStepProps {
  stop: IslandStop
  /** The line the learner already has, when it is changed from the island card. */
  initial?: IslandEntry
  frame: { step: LoopStep; steps: readonly LoopStep[]; index?: number }
  leaveHref: string
  /** Stores the line. Resolves false when it could not be saved. */
  onSave: (entry: IslandEntry) => Promise<boolean>
  /** Only for a stop the learner may skip (stop 21): moves on with no line. */
  onSkip?: () => void
}

function titleFor(stop: IslandStop, changing: boolean): string {
  if (changing) return 'Change your island line'
  return stop.stop === 1 ? 'Your first island line' : 'A new island line'
}

/** Plays one recording from the page's memory, as on Say it. */
function usePlayback() {
  const audio = useRef<HTMLAudioElement | null>(null)
  const url = useRef<string | null>(null)
  const release = useCallback(() => {
    audio.current?.pause()
    audio.current = null
    if (url.current) URL.revokeObjectURL(url.current)
    url.current = null
  }, [])
  const play = useCallback(
    (recording: Recording) => {
      release()
      url.current = URL.createObjectURL(new Blob([louderForPlayback(recording.wav)], { type: 'audio/wav' }))
      audio.current = new Audio(url.current)
      void audio.current.play().catch(() => undefined)
    },
    [release],
  )
  useEffect(() => release, [release])
  return { play, release }
}

export function IslandStep({ stop, initial, frame, leaveHref, onSave, onSkip }: IslandStepProps) {
  const choices = choicesOf(stop)
  const hasGaps = stop.name || stop.list !== null
  const [phase, setPhase] = useState<Phase>(hasGaps ? 'fill' : 'say')
  const [name, setName] = useState(initial?.name ?? '')
  const [choice, setChoice] = useState<number | null>(initial?.choice ?? null)
  const [showAll, setShowAll] = useState(
    initial?.choice !== undefined && initial.choice !== null && initial.choice >= SHOWN_FIRST,
  )
  const [rec, setRec] = useState<RecordState>(() => (recordingSupported() ? 'ready' : 'unavailable'))
  const [reason, setReason] = useState<string | undefined>(
    recordingSupported() ? undefined : 'Recording is not available in this browser.',
  )
  const [seconds, setSeconds] = useState(0)
  const [recording, setRecording] = useState<Recording | null>(null)
  const [problem, setProblem] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)
  const handle = useRef<RecorderHandle | null>(null)
  const heading = useRef<HTMLHeadingElement>(null)
  const playback = usePlayback()
  const steady = useSteadyPress()
  const nameId = useId()
  const listName = useId()

  const typedName = stop.name ? cleanName(name) : null
  const ready = (!stop.name || typedName !== null) && (stop.list === null || choice !== null)
  const filled = ready ? fillLine(stop, stop.list === null ? null : choice, typedName ?? '') : null

  // Each phase's heading takes focus, so a screen reader hears where the learner is.
  useEffect(() => {
    heading.current?.focus({ preventScroll: true })
  }, [phase])

  // The recording is let go when the learner leaves the step.
  useEffect(
    () => () => {
      handle.current?.cancel()
      handle.current = null
    },
    [],
  )

  async function finishRecording(result: Promise<Recording>) {
    handle.current = null
    setRec('working')
    try {
      const made = await result
      setRecording(made.durationMs >= MIN_RECORDING_MS ? made : null)
    } catch {
      setRecording(null)
    }
    setRec('ready')
  }

  async function record() {
    if (rec !== 'ready') return
    playback.release()
    setSeconds(0)
    setRec('recording')
    try {
      handle.current = await startRecording({
        onTick: setSeconds,
        onAutoStop: (result) => void finishRecording(result),
        onInterrupted: () => {
          handle.current = null
          setRec('ready')
        },
      })
    } catch (error) {
      handle.current = null
      setRec('unavailable')
      const denied = error instanceof RecorderFailed && error.problem === 'denied'
      setReason(denied ? 'Recording is off.' : 'Recording is not available in this browser.')
      if (denied) setProblem(MIC_OFF)
    }
  }

  function stopRecording() {
    const current = handle.current
    if (current) void finishRecording(current.stop())
  }

  async function add(event: MouseEvent<HTMLButtonElement>) {
    if (!steady.accept(event) || !filled || saving) return
    handle.current?.cancel()
    handle.current = null
    setSaving(true)
    setProblem(null)
    const entry: IslandEntry = {
      stop: stop.stop,
      choice: stop.list === null ? null : choice,
      ...(stop.name && typedName !== null ? { name: typedName } : {}),
    }
    const saved = await onSave(entry)
    setSaving(false)
    if (!saved) setProblem(NOT_SAVED_LINE)
  }

  const shown = showAll ? choices : choices.slice(0, SHOWN_FIRST)
  // The pattern with its gaps, for the fill phase: the typed name and the choice in peach, an empty
  // gap as a dashed outline.
  const frameLine = stop.spoken.split(/(\{[^{}]+\})/).map((part, index) => {
    if (part === '{name}') {
      return typedName ? (
        <span key={index} className={styles.gap}>
          {typedName}
        </span>
      ) : (
        <span key={index} className={`${styles.gap} ${styles.gapEmpty}`} lang="en">
          your name
        </span>
      )
    }
    if (part.startsWith('{') && part.endsWith('}')) {
      const picked = choice === null ? null : choices[choice]
      return picked ? (
        <span key={index} className={styles.gap}>
          {picked.spoken}
        </span>
      ) : (
        <span key={index} className={`${styles.gap} ${styles.gapEmpty}`} lang="en">
          choose
        </span>
      )
    }
    return <span key={index}>{part}</span>
  })

  if (phase === 'fill') {
    const gaps = (stop.name ? 1 : 0) + (stop.list === null ? 0 : 1)
    const actions = (
      <div className={voice.buttons}>
        <Button
          block
          disabled={!ready}
          onPointerDown={steady.onPointerDown}
          onClick={(event) => {
            if (steady.accept(event) && ready) setPhase('say')
          }}
        >
          Hear my line
        </Button>
        {onSkip && (
          <Button variant="quiet" onClick={onSkip}>
            Skip this line
          </Button>
        )}
      </div>
    )
    return (
      <SessionFrame
        step={frame.step}
        steps={frame.steps}
        index={frame.index}
        progress={0.3}
        leaveHref={leaveHref}
        actions={actions}
      >
        <main className={styles.main}>
          <div className={styles.heading}>
            <h1 className={`${screens.title} ${styles.focusTitle}`} ref={heading} tabIndex={-1}>
              {titleFor(stop, initial !== undefined)}
            </h1>
            <p className={styles.sub}>{gaps > 1 ? FILL_SUB_MANY : FILL_SUB_ONE}</p>
          </div>
          <div className={styles.card}>
            <p className={styles.frame} lang="fi" aria-live="polite">
              {frameLine}
            </p>
          </div>
          {stop.name && (
            <TextField
              id={nameId}
              label="Your first name"
              placeholder="Your first name"
              hint={NAME_HELP}
              autoComplete="given-name"
              autoCapitalize="words"
              spellCheck={false}
              maxLength={NAME_MAX}
              value={name}
              onChange={(event) => {
                setName(event.target.value)
              }}
            />
          )}
          {stop.list !== null && (
            <fieldset className={styles.choices}>
              <legend className={styles.choicesLabel}>Choose one</legend>
              {shown.map((option, index) => (
                <label key={option.written} className={styles.chip} lang="fi">
                  <input
                    type="radio"
                    name={listName}
                    checked={choice === index}
                    onChange={() => {
                      setChoice(index)
                    }}
                  />
                  {option.spoken}
                </label>
              ))}
              {!showAll && choices.length > SHOWN_FIRST && (
                <button
                  type="button"
                  className={styles.more}
                  aria-label={`Show all ${String(choices.length)} choices`}
                  onClick={() => {
                    setShowAll(true)
                  }}
                >
                  More…
                </button>
              )}
            </fieldset>
          )}
        </main>
      </SessionFrame>
    )
  }

  const triedHere = recording !== null && rec === 'ready'
  const actions = (
    <>
      {problem && <StatusLine tone="problem">{problem}</StatusLine>}
      <div className={voice.buttons}>
        <Button
          block
          busy={saving}
          busyLabel="Saving your line."
          disabled={!filled}
          onPointerDown={steady.onPointerDown}
          onClick={(event) => void add(event)}
        >
          {initial ? 'Save my line' : 'Add to my island'}
        </Button>
        {hasGaps && (
          <Button
            variant="quiet"
            onClick={() => {
              handle.current?.cancel()
              handle.current = null
              setRec(recordingSupported() ? 'ready' : 'unavailable')
              setPhase('fill')
            }}
          >
            Change my choice
          </Button>
        )}
        {!hasGaps && onSkip && (
          <Button variant="quiet" onClick={onSkip}>
            Skip this line
          </Button>
        )}
      </div>
    </>
  )
  return (
    <SessionFrame
      step={frame.step}
      steps={frame.steps}
      index={frame.index}
      progress={0.7}
      leaveHref={leaveHref}
      actions={actions}
    >
      <main className={styles.main}>
        <div className={styles.heading}>
          <h1 className={`${screens.title} ${styles.focusTitle}`} ref={heading} tabIndex={-1}>
            {hasGaps ? SAY_TITLE : titleFor(stop, initial !== undefined)}
          </h1>
        </div>
        {filled && <IslandLine filled={filled} />}
        {stop.name && <p className={styles.note}>{NAME_NOTE}</p>}
        <div className={styles.record}>
          <RecordControl
            state={rec}
            seconds={seconds}
            reason={reason}
            hints={RECORD_HINTS}
            readyHint={!triedHere}
            readyName={
              triedHere ? 'Try again, record yourself saying your line' : 'Record yourself saying your line'
            }
            onStart={() => void record()}
            onStop={stopRecording}
          />
          {triedHere && (
            <Button
              variant="quiet"
              onClick={() => {
                playback.play(recording)
              }}
            >
              Play mine
            </Button>
          )}
        </div>
      </main>
    </SessionFrame>
  )
}
