import { useEffect, useRef, useState } from 'react'
import { RecordControl, type RecordState } from '../components/RecordControl.tsx'
import { RecorderFailed, startRecording, type RecorderHandle } from '../lib/recorder.ts'
import type { AnswerMethodProps } from './answer-methods.ts'
import voice from './Voice.module.css'

// Saying the word, the second answer method of a review item
// (factory/jobs/10-speaking-feedback/spec.md, "Done when" 21). The microphone
// is asked for only when the learner presses record, and only an item that the
// answer mode rule made spoken shows this. The recording stays in this page's
// memory until it is sent to be checked; it is never stored. Any failure is
// handed to the screen, which switches the item to typing.

export function SpokenAnswer({ disabled, onRecorded }: AnswerMethodProps) {
  const [state, setState] = useState<RecordState>('ready')
  const [seconds, setSeconds] = useState(0)
  const handle = useRef<RecorderHandle | null>(null)

  // Leaving the item throws away a recording in progress.
  useEffect(
    () => () => {
      handle.current?.cancel()
      handle.current = null
    },
    [],
  )

  async function finished(result: ReturnType<RecorderHandle['stop']>) {
    handle.current = null
    setState('working')
    try {
      onRecorded({ kind: 'recorded', recording: await result })
    } catch {
      onRecorded({ kind: 'failed', problem: 'failed' })
    }
    setState('ready')
  }

  async function start() {
    if (state !== 'ready' || disabled) return
    setSeconds(0)
    setState('recording')
    try {
      handle.current = await startRecording({
        onTick: setSeconds,
        onAutoStop: (result) => void finished(result),
        onInterrupted: () => {
          handle.current = null
          setState('ready')
          onRecorded({ kind: 'failed', problem: 'background' })
        },
      })
    } catch (error) {
      handle.current = null
      setState('ready')
      onRecorded({ kind: 'failed', problem: error instanceof RecorderFailed ? error.problem : 'failed' })
    }
  }

  function stop() {
    const current = handle.current
    if (current) void finished(current.stop())
  }

  return (
    <div className={voice.recordRow}>
      <RecordControl
        state={disabled && state === 'ready' ? 'working' : state}
        seconds={seconds}
        onStart={() => void start()}
        onStop={stop}
      />
    </div>
  )
}
