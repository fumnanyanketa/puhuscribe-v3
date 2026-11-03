import { useCallback, useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { RecordControl, Wave, type RecordState } from '../components/RecordControl.tsx'
import { SessionFrame } from '../components/SessionFrame.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { PATHS } from '../lib/app-paths.ts'
import { useSteadyPress } from '../lib/use-steady-press.ts'
import {
  RecorderFailed,
  recordingSupported,
  startRecording,
  type RecorderHandle,
  type Recording,
} from '../lib/recorder.ts'
import type { SessionLine } from '../lib/session-types.ts'
import { feedbackMessage, type MessagePart } from '../lib/speech-feedback.ts'
import { MIN_RECORDING_MS, type VoiceAnswer } from '../lib/speech-types.ts'
import { voiceNotice } from '../lib/voice-consent.ts'
import { NOT_AVAILABLE, TOO_MANY, chooseVoice, loadVoice, sayLine } from '../lib/voice-api.ts'
import { FirstLessonTip } from './FirstLessonTip.tsx'
import { LineCard } from './LineCard.tsx'
import { ConsentSheet } from './ConsentSheet.tsx'
import { NOT_SAVED, type StepScreenProps } from './step-screen.ts'
import styles from './Screens.module.css'
import voice from './Voice.module.css'
import { louderForPlayback } from '../lib/wav.ts'

// Saying lines out loud, in two steps of a session (owner's fast route
// hear-and-say, 3 November 2026: "Hear + say per line, short recap").
//
// "Hear it, say it" (variant "hear", the session's first step, HearIt.tsx):
// each line of the dialogue shows as Hear it showed it (the spoken and written
// lines with their play buttons, the Meaning line, tappable words; nothing
// plays by itself), then the learner records themselves saying it back and
// gets one kind message, then "Next line". A learner without speaking feedback
// ("Not now", or withdrawn), or who chose "I can't speak right now", hears each
// line and moves on with "Next line", as in Hear it. On the learner's first
// lesson the tip explains the card first; the recorder and the consent sheet
// wait until it is closed. The last line's "Continue" stores step "hear".
//
// The recap (variant "recap", step "Recap", stored as "say"): only the key
// lines the session names (at most three, worker/session-plan.ts keyLinesOf),
// said from memory. The card shows the line's English meaning; the Finnish
// shows after the attempt or on "Show the Finnish". "I can't speak right now"
// ends the recap, as it ended Say it.
//
// Both keep Say it's rules (factory/jobs/10-speaking-feedback/spec.md, "Done
// when" 1, 3 and 5 to 9, 13 and 15): before the first recording the consent
// sheet asks, and nothing is recorded until the learner agrees; every failure
// leaves "Next line" or "Continue" possible; the recording stays in this page's
// memory and is let go when the learner moves on or leaves.

export const SAY_HELP = 'Listen to the line, then record yourself saying it.'
/** The hints under the record button (job 19-redesign, statement 30). */
/** As drawn, with no full stop (round 6). */
export const RECORD_HINTS = { ready: 'Tap and say the line', recording: 'Listening' }
/** The recap's hints: the Finnish is not shown yet, so the learner says it from memory. */
export const RECAP_HINTS = { ready: 'Tap and say it in Finnish', recording: 'Listening' }
/** The recap without speaking feedback. */
export const RECAP_ALOUD = 'Say it out loud from memory, then show the Finnish.'
export const SHOW_FINNISH = 'Show the Finnish'
export const NO_RECORDING = 'Recording is not available in this browser.'
export const MIC_OFF =
  'Microphone access is off. You can turn it on in your browser settings, or carry on without recording.'
export const BACKGROUND = 'Recording stopped because the app was in the background. Try again.'
export const NOT_CHECKED =
  'Your recording could not be checked. Check your internet connection, then try again.'
export const CHOICE_NOT_SAVED = 'Your choice was not saved. Check your internet connection, then try again.'
export const CANT_SPEAK = "I can't speak right now"
/** The most lines the recap asks for when the session names no key lines. */
const RECAP_FALLBACK = 3
const LOADING = 'Loading speaking feedback.'
const NOT_HEARD = feedbackMessage({ feedbackClass: 'not_heard' })

/**
 * "record": the recorder. "aloud": no speaking feedback ("Not now", or withdrawn). "listen": the learner
 * chose "I can't speak right now" in Hear it, say it, and hears the rest of the lines.
 */
type Mode = 'loading' | 'consent' | 'record' | 'aloud' | 'listen'

export type SpeakVariant = 'hear' | 'recap'

/**
 * The sessions in which the learner answered "Not now" on this page, so the recap does not ask again
 * in the same lesson. Kept in this page's memory only: after a reload the sheet asks again, as before.
 */
const notNowIn = new Set<string>()

interface Message {
  tone: StatusTone
  parts: MessagePart[]
}

/**
 * What the learner did on one line, kept while the step is open so "Previous line" brings it back (fast
 * route go-back): the try, its feedback and whether the Finnish was shown. The recording stays in this
 * page's memory only and is let go when the step ends or the learner leaves.
 */
interface LineMemory {
  recording: Recording | null
  message: Message | null
  clear: boolean
  attempted: boolean
  askedFinnish: boolean
}

export const PREVIOUS_LINE = 'Previous line'

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

/**
 * The recap's lines: the key lines the session names, in line order, or the first three lines when it
 * names none.
 */
export function recapLines(
  lines: readonly SessionLine[],
  keyLines: readonly number[] | undefined,
): SessionLine[] {
  const named = keyLines ? lines.filter((line) => keyLines.includes(line.id)) : []
  return named.length > 0 ? named : lines.slice(0, RECAP_FALLBACK)
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
      url.current = URL.createObjectURL(new Blob([louderForPlayback(recording.wav)], { type: 'audio/wav' }))
      audio.current = new Audio(url.current)
      void audio.current.play().catch(() => undefined)
    },
    [release],
  )
  useEffect(() => release, [release])
  return { play, release }
}

/** The recap (step "Recap"): the key lines, said from memory. */
export function SayIt(props: StepScreenProps) {
  return <SpeakLines {...props} variant="recap" />
}

export function SpeakLines({
  session,
  frame,
  onDone,
  variant,
  practice = false,
}: StepScreenProps & { variant: SpeakVariant }) {
  const hear = variant === 'hear'
  const [lines] = useState(() => (hear ? session.lines : recapLines(session.lines, session.keyLines)))
  const sessionId = session.session.id
  const [mode, setMode] = useState<Mode>('loading')
  const [settings, setSettings] = useState<VoiceAnswer | null>(null)
  const [clear, setClear] = useState(false)
  const [choosing, setChoosing] = useState(false)
  const [index, setIndex] = useState(0)
  const [rec, setRec] = useState<RecordState>('ready')
  const [reason, setReason] = useState<string | undefined>(undefined)
  const [seconds, setSeconds] = useState(0)
  const [message, setMessage] = useState<Message | null>(null)
  const [attempted, setAttempted] = useState(false)
  const [recording, setRecording] = useState<Recording | null>(null)
  const [saving, setSaving] = useState(false)
  // The recap shows the Finnish after a try, or when the learner asks for it.
  const [askedFinnish, setAskedFinnish] = useState(false)
  // The first lesson's tip (job 19-redesign, statement 25), in Hear it, say it only.
  const [tip, setTip] = useState(hear && session.firstLesson === true)
  const handle = useRef<RecorderHandle | null>(null)
  const status = useRef<HTMLParagraphElement>(null)
  const region = useRef<HTMLElement>(null)
  // Where focus goes when the tip closes: "Next line", or "I can't speak right now" before a try.
  const afterTip = useRef<HTMLButtonElement>(null)
  const firstLoad = useRef<ReturnType<typeof loadVoice> | null>(null)
  const playback = usePlayback()
  const steady = useSteadyPress()
  // The quiet "Turn on speaking feedback" opens the consent sheet and goes while it is open, so focus is given back
  // to it by hand once the sheet has closed (Safari does not focus a tapped button, round 5).
  const reopen = useRef<HTMLButtonElement>(null)
  const reopened = useRef(false)
  const line = lines.at(index)
  const last = index + 1 >= lines.length
  // Each line's try, kept for "Previous line"; the line on screen now, so a late result is not shown on another.
  const kept = useRef(new Map<number, LineMemory>())
  const onLine = useRef(0)
  const focusAfterBack = useRef(false)

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
        window.location.replace(PATHS.home)
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
      else if (load.voice.processing === 'withdrawn' || notNowIn.has(sessionId)) setMode('aloud')
      else setMode('consent')
    })
    return () => {
      active = false
    }
  }, [enterRecording, sessionId])

  // After the consent sheet that the quiet button opened has closed, focus goes back to that button.
  useEffect(() => {
    if (mode === 'aloud' && reopened.current) {
      reopened.current = false
      reopen.current?.focus()
    }
  }, [mode])

  // Back on the first line, "Previous line" is unavailable, so focus moves to the line's next action.
  useEffect(() => {
    if (focusAfterBack.current) {
      focusAfterBack.current = false
      afterTip.current?.focus()
    }
  }, [index])

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
    setClear(false)
    setAttempted(false)
    setAskedFinnish(false)
    setSeconds(0)
    setRec((now) => (now === 'unavailable' ? now : 'ready'))
  }

  /** Moves to another line, keeping this line's try and bringing back the other line's. */
  function goTo(target: number) {
    handle.current?.cancel()
    handle.current = null
    playback.release()
    kept.current.set(index, {
      recording,
      message,
      clear,
      attempted,
      askedFinnish,
    })
    const back = kept.current.get(target)
    setRecording(back?.recording ?? null)
    setMessage(back?.message ?? null)
    setClear(back?.clear ?? false)
    setAttempted(back?.attempted ?? false)
    setAskedFinnish(back?.askedFinnish ?? false)
    setSeconds(0)
    setRec((now) => (now === 'unavailable' ? now : 'ready'))
    onLine.current = target
    setIndex(target)
  }

  function previous() {
    if (index === 0) return
    if (index === 1) focusAfterBack.current = true
    goTo(index - 1)
  }

  async function finishStep() {
    kept.current.clear()
    letGoOfLine()
    setSaving(true)
    const saved = await onDone()
    if (!saved) {
      setSaving(false)
      setMessage(plain('problem', NOT_SAVED))
    }
  }

  function next(event?: { detail: number }) {
    if (!steady.accept(event)) return
    if (last) {
      void finishStep()
      return
    }
    goTo(index + 1)
  }

  function cantSpeak() {
    // In Hear it, say it the learner still hears every line; the recap ends, as Say it did.
    if (!hear) {
      void finishStep()
      return
    }
    letGoOfLine()
    setMode('listen')
  }

  async function turnOn() {
    setChoosing(true)
    setMessage(null)
    // The retention box is not on this sheet: it stays unticked and can be turned on in Voice settings.
    const load = await chooseVoice('turn_on', false)
    setChoosing(false)
    if (load.kind === 'signed_out') {
      window.location.replace(PATHS.home)
      return
    }
    if (load.kind !== 'ok') {
      setMessage(plain('problem', CHOICE_NOT_SAVED))
      return
    }
    notNowIn.delete(sessionId)
    setSettings(load.voice)
    enterRecording(load.voice)
  }

  async function checked(result: Promise<Recording>) {
    handle.current = null
    setRec('working')
    const mine = onLine.current
    let made: Recording
    try {
      made = await result
    } catch {
      if (onLine.current !== mine) return
      setRec('ready')
      setAttempted(true)
      setMessage(plain('problem', NOT_CHECKED))
      return
    }
    if (onLine.current !== mine) return
    setRecording(made)
    setAttempted(true)
    if (made.durationMs < MIN_RECORDING_MS || !line) {
      setRec('ready')
      setMessage(NOT_HEARD)
      return
    }
    const answer = await sayLine(sessionId, line.id, made.wav, practice)
    // The learner moved to another line while this one was checked: the result belongs to that line only.
    if (onLine.current !== mine) return
    switch (answer.kind) {
      case 'feedback':
        setRec('ready')
        setClear(answer.feedback.feedbackClass === 'clear')
        setMessage(feedbackMessage(answer.feedback))
        return
      case 'signed_out':
        window.location.replace(PATHS.home)
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
    setClear(false)
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
  const listening = mode === 'aloud' || mode === 'listen'
  const canMoveOn = listening || attempted || rec === 'unavailable'
  // A clear result is a milky card with its wave (statement 30); every other
  // result is the status line, gentle for the learner's attempts.
  const showClear = clear && recording !== null && rec === 'ready' && mode === 'record'
  const statusShown = showClear || mode === 'consent' ? null : shown
  // A gentle result (the learner's try) is the peach note above the record button, as drawn (round 6);
  // every other line stays at the bottom. "Line 1 of 3." is for screen readers only.
  const noteAbove = statusShown !== null && statusShown.tone === 'gentle' && mode === 'record'
  const triedHere = recording !== null && rec === 'ready' && !showClear
  // Hear it, say it shows the line while speaking feedback loads; the recap waits, as Say it did.
  const cardShown = hear || mode !== 'loading'
  // The recorder waits while the first lesson's tip is open.
  const recorderShown = mode === 'record' && !tip

  // Hear it, say it: Hear it's line card. The recap: the card without play buttons, its Finnish covered by
  // "Show the Finnish" until the learner has tried or asked.
  const finnishCovered = !hear && !askedFinnish && !attempted
  const card = line && (
    <LineCard
      line={line}
      showGloss
      count={hear ? { shown: index + 1, of: lines.length } : undefined}
      controls={hear}
      cover={
        finnishCovered ? (
          <Button
            variant="quiet"
            onClick={() => {
              setAskedFinnish(true)
            }}
          >
            {SHOW_FINNISH}
          </Button>
        ) : undefined
      }
    />
  )

  const actions = (
    <>
      {statusShown && !noteAbove && (
        <StatusLine ref={status} tone={statusShown.tone} visuallyHidden={statusShown === counter}>
          <Parts parts={statusShown.parts} />
        </StatusLine>
      )}
      {mode !== 'loading' && mode !== 'consent' && (
        <div className={voice.buttons}>
          {(canMoveOn || index > 0) && (
            <div className={voice.lineNav}>
              {/* Back to the line before, with what was said on it (fast route go-back). Beside "Next line"
                  it keeps its place on the first line, unavailable there. */}
              {lines.length > 1 && (
                <button
                  type="button"
                  className={voice.previous}
                  aria-label={PREVIOUS_LINE}
                  disabled={index === 0 || saving}
                  onClick={previous}
                >
                  <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                    <path d="M19 12H5M11 6l-6 6 6 6" />
                  </svg>
                </button>
              )}
              {canMoveOn && (
                <div className={voice.lineNavMain}>
                  <Button
                    block
                    ref={afterTip}
                    busy={saving}
                    busyLabel={practice ? 'Moving on.' : 'Saving your progress.'}
                    onPointerDown={steady.onPointerDown}
                    onClick={next}
                  >
                    {last ? 'Continue' : 'Next line'}
                  </Button>
                </div>
              )}
            </div>
          )}
          {mode === 'record' && (
            <Button variant="quiet" ref={canMoveOn ? undefined : afterTip} onClick={cantSpeak}>
              {CANT_SPEAK}
            </Button>
          )}
          {mode === 'aloud' && settings?.available && (
            <Button
              ref={reopen}
              variant="quiet"
              onClick={() => {
                reopened.current = true
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

  // Hear it, say it: half a line for hearing it, the other half once it is said (or for moving on
  // without speaking). The recap: a line once it is tried.
  const done = hear ? (attempted || listening ? 1 : 0.5) : attempted ? 1 : 0
  return (
    <SessionFrame
      step={frame.step}
      steps={frame.steps}
      progress={(index + done) / Math.max(1, lines.length)}
      leaveHref={PATHS.home}
      stepHeading
      dim={tip}
      actions={actions}
    >
      {/* While the tip is open the tip sits right under the card, as in Hear it; after it, the room is filled
          so the record button sits in the middle, as in Say it. */}
      <main className={tip ? styles.main : `${styles.main} ${styles.mainFill}`} ref={region}>
        {line && cardShown && (
          <div className={voice.lineArea} key={line.id} data-say-line={line.id}>
            {card}
            {mode === 'aloud' && !hear && <p className={voice.hint}>{RECAP_ALOUD}</p>}
            {recorderShown && !showClear && (
              <div className={voice.recordRow}>
                {noteAbove && (
                  <StatusLine ref={status} tone={statusShown.tone}>
                    <Parts parts={statusShown.parts} />
                  </StatusLine>
                )}
                {/* After a try, the record button itself is "Try again", as drawn; "Play mine" stays as a small
                    link, because the learner can always hear their own try (job 10, statement 8). */}
                <RecordControl
                  state={rec}
                  seconds={seconds}
                  reason={reason}
                  hints={hear ? RECORD_HINTS : RECAP_HINTS}
                  readyHint={!triedHere}
                  readyName={triedHere ? 'Try again, record yourself saying the line' : undefined}
                  onStart={() => void record()}
                  onStop={stop}
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
            )}
            {showClear && (
              <section className={voice.clearCard} aria-label="Your recording">
                <p className={voice.clearLine} role="status" data-tone="neutral" ref={status}>
                  <span className={voice.checkCircle} aria-hidden="true">
                    <svg viewBox="0 0 24 24" focusable="false">
                      <path d="M5 12.5l4.5 4.5L19 7.5" />
                    </svg>
                  </span>
                  {shown ? <Parts parts={shown.parts} /> : null}
                </p>
                <Wave />
                <div className={voice.recordingControls}>
                  <Button
                    variant="secondary"
                    onClick={() => {
                      playback.play(recording)
                    }}
                  >
                    Play mine
                  </Button>
                  <Button variant="secondary" onClick={() => void record()}>
                    Try again
                  </Button>
                </div>
              </section>
            )}
          </div>
        )}
        {tip && (
          <FirstLessonTip
            region={region}
            restoreFocusTo={afterTip}
            onClose={() => {
              setTip(false)
            }}
          />
        )}
      </main>
      <ConsentSheet
        open={mode === 'consent' && !tip}
        region={settings?.region ?? null}
        busy={choosing}
        problem={mode === 'consent' && message ? <Parts parts={message.parts} /> : undefined}
        onTurnOn={() => void turnOn()}
        onNotNow={() => {
          notNowIn.add(sessionId)
          setMessage(null)
          setMode('aloud')
        }}
      />
    </SessionFrame>
  )
}
