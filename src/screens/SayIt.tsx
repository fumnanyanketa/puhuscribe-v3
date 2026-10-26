import { useCallback, useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { RecordControl, type RecordState } from '../components/RecordControl.tsx'
import { SessionFrame } from '../components/SessionFrame.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import {
  RecorderFailed,
  recordingSupported,
  startRecording,
  type RecorderHandle,
  type Recording,
} from '../lib/recorder.ts'
import { feedbackMessage, type MessagePart } from '../lib/speech-feedback.ts'
import { MIN_RECORDING_MS, type VoiceAnswer } from '../lib/speech-types.ts'
import { voiceNotice } from '../lib/voice-consent.ts'
import { NOT_AVAILABLE, TOO_MANY, chooseVoice, loadVoice, sayLine } from '../lib/voice-api.ts'
import { LineCard } from './LineCard.tsx'
import { NOT_SAVED, type StepScreenProps } from './step-screen.ts'
import { VoiceConsent } from './VoiceConsent.tsx'
import styles from './Screens.module.css'
import voice from './Voice.module.css'

// Say it (factory/jobs/10-speaking-feedback/spec.md, "Done when" 1, 3 and 5
// to 9, 13 and 15). The learner hears each line, records themselves saying
// it, and gets one kind message. Before the first recording the consent
// screen asks; nothing is recorded until they agree, and "Not now" still lets
// them say each line out loud without feedback. Every failure leaves "Next
// line" or "Continue" possible. The recording stays in this page's memory and
// is let go when the learner moves on or leaves.

export const SAY_HELP = 'Listen to the line, then record yourself saying it.'
export const ALOUD = 'Say the line out loud after the voice.'
export const NO_RECORDING = 'Recording is not available in this browser.'
export const MIC_OFF =
  'Microphone access is off. You can turn it on in your browser settings, or carry on without recording.'
export const BACKGROUND = 'Recording stopped because the app was in the background. Try again.'
export const NOT_CHECKED =
  'Your recording could not be checked. Check your internet connection, then try again.'
export const CHOICE_NOT_SAVED = 'Your choice was not saved. Check your internet connection, then try again.'
export const CANT_SPEAK = "I can't speak right now"
const LOADING = 'Loading speaking feedback.'
const NOT_HEARD = feedbackMessage({ feedbackClass: 'not_heard' })

type Mode = 'loading' | 'consent' | 'record' | 'aloud'

interface Message {
  tone: StatusTone
  parts: MessagePart[]
}

function plain(tone: StatusTone, text: string): Message {
  return { tone, parts: [text] }
}

function Parts({ parts }: { parts: MessagePart[] }) {
  return parts.map((part, i) =>
    typeof part === 'string' ? (
      <span key={i}>{part}</span>
    ) : (
      <span key={i} lang="fi">
        {part.fi}
      </span>
    ),
  )
}

/** Plays one recording from the page's memory. */
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
      // A fresh copy: the Blob owns its bytes and goes when the URL is revoked.
      url.current = URL.createObjectURL(new Blob([recording.wav.slice()], { type: 'audio/wav' }))
      audio.current = new Audio(url.current)
      void audio.current.play().catch(() => undefined)
    },
    [release],
  )
  useEffect(() => release, [release])
  return { play, release }
}

export function SayIt({ session, frame, onDone }: StepScreenProps) {
  const lines = session.lines
  const [mode, setMode] = useState<Mode>('loading')
  const [settings, setSettings] = useState<VoiceAnswer | null>(null)
  const [keep, setKeep] = useState(false)
  const [choosing, setChoosing] = useState(false)
  const [index, setIndex] = useState(0)
  const [rec, setRec] = useState<RecordState>('ready')
  const [reason, setReason] = useState<string | undefined>(undefined)
  const [seconds, setSeconds] = useState(0)
  const [message, setMessage] = useState<Message | null>(null)
  const [attempted, setAttempted] = useState(false)
  const [recording, setRecording] = useState<Recording | null>(null)
  const [saving, setSaving] = useState(false)
  const handle = useRef<RecorderHandle | null>(null)
  const status = useRef<HTMLParagraphElement>(null)
  const firstLoad = useRef<ReturnType<typeof loadVoice> | null>(null)
  const playback = usePlayback()
  const line = lines.at(index)
  const last = index + 1 >= lines.length

  const enterRecording = useCallback((answer: VoiceAnswer) => {
    setMode('record')
    if (!answer.available) {
      setRec('unavailable')
      setReason(NOT_AVAILABLE)
    } else if (!recordingSupported()) {
      setRec('unavailable')
      setReason(NO_RECORDING)
    } else {
      setRec('ready')
      setReason(undefined)
    }
  }, [])

  useEffect(() => {
    let active = true
    firstLoad.current ??= loadVoice()
    void firstLoad.current.then((load) => {
      if (!active) return
      if (load.kind === 'signed_out') {
        window.location.replace('/')
        return
      }
      if (load.kind === 'failed') {
        enterRecording({
          available: false,
          region: null,
          processing: 'not_asked',
          retention: false,
          recordings: [],
        })
        return
      }
      setSettings(load.voice)
      if (!load.voice.available || load.voice.processing === 'granted') enterRecording(load.voice)
      else setMode(load.voice.processing === 'withdrawn' ? 'aloud' : 'consent')
    })
    return () => {
      active = false
    }
  }, [enterRecording])

  // Leaving the screen throws away a recording in progress.
  useEffect(
    () => () => {
      handle.current?.cancel()
      handle.current = null
    },
    [],
  )

  function letGoOfLine() {
    handle.current?.cancel()
    handle.current = null
    playback.release()
    setRecording(null)
    setMessage(null)
    setAttempted(false)
    setSeconds(0)
    setRec((now) => (now === 'unavailable' ? now : 'ready'))
  }

  async function finishStep() {
    letGoOfLine()
    setSaving(true)
    const saved = await onDone()
    if (!saved) {
      setSaving(false)
      setMessage(plain('problem', NOT_SAVED))
    }
  }

  function next() {
    if (last) {
      void finishStep()
      return
    }
    letGoOfLine()
    setIndex(index + 1)
  }

  async function turnOn() {
    setChoosing(true)
    setMessage(null)
    const load = await chooseVoice('turn_on', keep)
    setChoosing(false)
    if (load.kind === 'signed_out') {
      window.location.replace('/')
      return
    }
    if (load.kind !== 'ok') {
      setMessage(plain('problem', CHOICE_NOT_SAVED))
      return
    }
    setSettings(load.voice)
    enterRecording(load.voice)
  }

  async function checked(result: Promise<Recording>) {
    handle.current = null
    setRec('working')
    let made: Recording
    try {
      made = await result
    } catch {
      setRec('ready')
      setAttempted(true)
      setMessage(plain('problem', NOT_CHECKED))
      return
    }
    setRecording(made)
    setAttempted(true)
    if (made.durationMs < MIN_RECORDING_MS || !line) {
      setRec('ready')
      setMessage(NOT_HEARD)
      return
    }
    const answer = await sayLine(session.session.id, line.id, made.wav)
    switch (answer.kind) {
      case 'feedback':
        setRec('ready')
        setMessage(feedbackMessage(answer.feedback))
        return
      case 'signed_out':
        window.location.replace('/')
        return
      case 'no_consent':
        letGoOfLine()
        setMode('consent')
        return
      case 'not_available':
        setRec('unavailable')
        setReason(NOT_AVAILABLE)
        setMessage(null)
        return
      case 'too_many':
        setRec('ready')
        setMessage(plain('neutral', TOO_MANY))
        return
      case 'failed':
        setRec('ready')
        setMessage(plain('problem', NOT_CHECKED))
    }
  }

  async function record() {
    if (rec !== 'ready') return
    playback.release()
    setMessage(null)
    setSeconds(0)
    setRec('recording')
    try {
      handle.current = await startRecording({
        onTick: setSeconds,
        onAutoStop: (result) => void checked(result),
        onInterrupted: () => {
          handle.current = null
          setRec('ready')
          setMessage(plain('problem', BACKGROUND))
        },
      })
    } catch (error) {
      handle.current = null
      const problem = error instanceof RecorderFailed ? error.problem : 'failed'
      setRec('unavailable')
      if (problem === 'denied') {
        setReason('Recording is off.')
        setMessage(plain('problem', MIC_OFF))
      } else {
        setReason(NO_RECORDING)
        setMessage(plain('problem', NO_RECORDING))
      }
    }
  }

  function stop() {
    const current = handle.current
    if (current) void checked(current.stop())
  }

  const notice = voiceNotice(settings?.region ?? null)
  const counter = plain('neutral', `Line ${String(index + 1)} of ${String(lines.length)}.`)
  const shown =
    mode === 'loading' ? plain('neutral', LOADING) : (message ?? (mode === 'consent' ? null : counter))
  const canMoveOn = mode === 'aloud' || attempted || rec === 'unavailable'

  const actions =
    mode === 'consent' ? (
      <>
        {shown && (
          <StatusLine ref={status} tone={shown.tone}>
            <Parts parts={shown.parts} />
          </StatusLine>
        )}
        <div className={voice.buttons}>
          <Button block busy={choosing} busyLabel="Saving your choice." onClick={() => void turnOn()}>
            {notice.turnOn}
          </Button>
          <Button
            block
            variant="secondary"
            onClick={() => {
              setMessage(null)
              setMode('aloud')
            }}
          >
            {notice.notNow}
          </Button>
        </div>
      </>
    ) : (
      <>
        {shown && (
          <StatusLine ref={status} tone={shown.tone}>
            <Parts parts={shown.parts} />
          </StatusLine>
        )}
        {mode !== 'loading' && (
          <div className={voice.buttons}>
            {canMoveOn && (
              <Button block busy={saving} busyLabel="Saving your progress." onClick={next}>
                {last ? 'Continue' : 'Next line'}
              </Button>
            )}
            {mode === 'record' && (
              <Button variant="quiet" onClick={() => void finishStep()}>
                {CANT_SPEAK}
              </Button>
            )}
            {mode === 'aloud' && settings?.available && (
              <Button
                variant="quiet"
                onClick={() => {
                  letGoOfLine()
                  setMode('consent')
                }}
              >
                {notice.turnOn}
              </Button>
            )}
          </div>
        )}
      </>
    )

  return (
    <SessionFrame step={frame.step} steps={frame.steps} leaveHref="/" actions={actions}>
      <main className={styles.main}>
        {mode === 'consent' ? (
          <VoiceConsent
            region={settings?.region ?? null}
            keep={keep}
            onKeepChange={setKeep}
            headingLevel={1}
          />
        ) : (
          <>
            <div className={styles.intro}>
              <h1 className={styles.title}>Say it</h1>
              <p className={styles.lead}>{session.dialogue.title}</p>
              <p className={styles.help}>{mode === 'aloud' ? ALOUD : SAY_HELP}</p>
              <a className={voice.link} href="/voice">
                Voice settings
              </a>
            </div>
            {line && mode !== 'loading' && (
              <div className={voice.lineArea} key={line.id} data-say-line={line.id}>
                <LineCard line={line} speakerAs="p" />
                {mode === 'record' && (
                  <div className={voice.recordRow}>
                    <RecordControl
                      state={rec}
                      seconds={seconds}
                      reason={reason}
                      onStart={() => void record()}
                      onStop={stop}
                    />
                    {recording && rec === 'ready' && (
                      <div className={voice.recordingControls}>
                        <Button
                          variant="secondary"
                          onClick={() => {
                            playback.play(recording)
                          }}
                        >
                          Play my recording
                        </Button>
                        <Button variant="secondary" onClick={() => void record()}>
                          Try again
                        </Button>
                      </div>
                    )}
                  </div>
                )}
              </div>
            )}
          </>
        )}
      </main>
    </SessionFrame>
  )
}
