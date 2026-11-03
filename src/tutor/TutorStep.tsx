import { useEffect, useId, useRef, useState, type ReactNode, type SyntheticEvent } from 'react'
import { Button } from '../components/Button.tsx'
import { FinnishLine } from '../components/FinnishLine.tsx'
import type { LineWord } from '../components/finnish.ts'
import { restoreCaretAfterLetter } from '../components/answer-field-caret.ts'
import { PlayControl } from '../components/PlayControl.tsx'
import { MicIcon } from '../components/RecordControl.tsx'
import { SessionFrame } from '../components/SessionFrame.tsx'
import { Sheet } from '../components/Sheet.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { PATHS } from '../lib/app-paths.ts'
import { startRecording, recordingSupported, type RecorderHandle } from '../lib/recorder.ts'
import type { SessionLine, SessionWord } from '../lib/session-types.ts'
import { TUTOR_NOTICE } from '../lib/tutor-consent.ts'
import {
  OTSO_CAP,
  OTSO_ENDS,
  OTSO_UNAVAILABLE,
  type TutorHistoryItem,
  type TutorState,
  type TutorTip,
} from '../lib/tutor-types.ts'
import { MAX_TUTOR_REPLY, pickOpening, TUTOR_TURNS } from '../lib/tutor-words.ts'
import { chooseVoice } from '../lib/voice-api.ts'
import { CARD_AUDIO_CAPTION, LINE_AUDIO, lineWords } from '../screens/LineCard.tsx'
import type { SessionStep } from '../screens/session-steps.ts'
import type { StepScreenProps } from '../screens/step-screen.ts'
import { OtsoAvatar, OtsoName } from './OtsoAvatar.tsx'
import { chooseTutor, sendTurn, transcribe } from './tutor-api.ts'
import styles from './Tutor.module.css'

// "Use it" with Otso, the AI tutor (factory/jobs/16-tutor-step/spec.md, with the owner's answers and
// the mockup of 3 November 2026). From stop 4 a session ends with three short turns: Otso opens with
// an approved line of today's dialogue, the learner answers by typing or speaking, and Otso answers
// with a line made by AI from words the learner has met, checked by the Worker. Otso's lines sit on
// the left as milky bubbles with the English under them; the learner's answers sit on the right in
// mint. At the end Otso may point to one approved line, the tip.
//
// Nothing here is stored: the chat lives in this screen's memory and is gone when it closes. Nothing
// says whether the learner's Finnish was right. The step stores no session step either: "Continue",
// "Stop here" and every problem move on to the next step or the finish screen.

export const TUTOR_TITLE = 'Talk with Otso'
export const TUTOR_SUB = 'Three short turns. Answer in your own words.'
export const TUTOR_DONE = 'Nicely done'
export const AI_NOTE = "Otso's replies are written by AI and checked to use only words you know."
export const GUEST_TEXT =
  'Otso is a short chat at the end of each lesson from stop 4. Add your email to talk with him, so your progress stays with your account.'
export const VOICE_TITLE = 'Speak to Otso'
export const VOICE_TEXT =
  "Your recording goes to Microsoft's speech service in the EU, which turns it into text. That text goes to Anthropic in the United States so Otso can answer. PuhuScribe keeps neither the recording nor the text. Turning this on also turns on speaking feedback in your lessons."

/** Otso's step for a session, with the state the session screen read as it loaded. */
export function tutorStepFor(state: TutorState): SessionStep {
  function TutorScreen(props: StepScreenProps) {
    return <TutorStep {...props} initial={state} />
  }
  return { id: 'tutor', name: 'Use it', Screen: TutorScreen }
}

type ChatItem =
  | { id: number; who: 'line'; line: SessionLine }
  | { id: number; who: 'ai'; text: string; words: SessionWord[]; meaning?: string }
  | { id: number; who: 'end' }
  | { id: number; who: 'you'; text: string }

type Phase = 'typing' | 'sending' | 'closed' | 'cap' | 'unavailable'

/** The text of a line as the learner sees it, for the history the Worker checks again. */
function lineText(line: SessionLine): string {
  return line.spoken.map((w) => `${w.before ?? ''}${w.text}${w.after ?? ''}`).join(' ')
}

/** The words of an AI line; a word with a met form opens its card with a line of today's dialogue that has it. */
function aiLineWords(words: readonly SessionWord[], lines: readonly SessionLine[]): LineWord[] {
  return words.map((word) => {
    const form = word.form
    const home = form
      ? lines.find((line) =>
          line.spoken.some((w) => w.form?.spoken === form.spoken && w.form.written === form.written),
        )
      : undefined
    const built = home ? lineWords([word], home)[0] : undefined
    return (
      built ?? {
        text: word.text,
        ...(word.before ? { before: word.before } : {}),
        ...(word.after ? { after: word.after } : {}),
      }
    )
  })
}

interface TutorStepProps extends StepScreenProps {
  initial: TutorState
}

export function TutorStep({ session, frame, onDone, initial }: TutorStepProps) {
  const [mode, setMode] = useState<'consent' | 'guest' | 'chat'>(
    initial.offer === 'guest' ? 'guest' : initial.offer === 'consent' ? 'consent' : 'chat',
  )
  const [busy, setBusy] = useState(false)
  const [problem, setProblem] = useState(false)
  const leave = () => void onDone()

  if (mode === 'guest') {
    return (
      <SessionFrame
        step={frame.step}
        steps={frame.steps}
        index={frame.index}
        leaveHref={PATHS.home}
        actions={
          <>
            <Button
              block
              onClick={() => {
                window.location.assign(PATHS.accountEmail)
              }}
            >
              Add your email
            </Button>
            <Button variant="secondary" block arrow={false} onClick={leave}>
              Continue
            </Button>
          </>
        }
      >
        <main className={styles.main}>
          <section className={styles.card} aria-labelledby="otso-guest-title">
            <div className={styles.cardHead}>
              <OtsoAvatar />
              <h1 id="otso-guest-title" className={styles.cardTitle}>
                {TUTOR_TITLE}
              </h1>
            </div>
            <p className={styles.cardText}>{GUEST_TEXT}</p>
          </section>
        </main>
      </SessionFrame>
    )
  }

  if (mode === 'consent') {
    return (
      <SessionFrame
        step={frame.step}
        steps={frame.steps}
        index={frame.index}
        leaveHref={PATHS.home}
        actions={
          <>
            {problem && (
              <StatusLine tone="problem">
                Your choice was not saved. Check your internet connection, then try again.
              </StatusLine>
            )}
            <Button
              block
              busy={busy}
              busyLabel="Saving your choice."
              onClick={() => {
                setBusy(true)
                setProblem(false)
                void chooseTutor('on').then((saved) => {
                  setBusy(false)
                  if (saved) setMode('chat')
                  else setProblem(true)
                })
              }}
            >
              {TUTOR_NOTICE.turnOn}
            </Button>
            <Button
              variant="quiet"
              disabled={busy}
              onClick={() => {
                // "Not now" is a choice too: later sessions leave Otso out until the account page turns him on.
                void chooseTutor('off').then(() => onDone())
              }}
            >
              {TUTOR_NOTICE.notNow}
            </Button>
          </>
        }
      >
        <main className={styles.main}>
          <section className={styles.card} aria-labelledby="otso-consent-title">
            <div className={styles.cardHead}>
              <OtsoAvatar />
              <h1 id="otso-consent-title" className={styles.cardTitle}>
                {TUTOR_NOTICE.heading}
              </h1>
            </div>
            {TUTOR_NOTICE.paragraphs.map((text) => (
              <p key={text} className={styles.cardText}>
                {text}
              </p>
            ))}
          </section>
        </main>
      </SessionFrame>
    )
  }

  return <TutorChat session={session} frame={frame} onDone={onDone} initial={initial} />
}

function TutorChat({ session, frame, onDone, initial }: TutorStepProps) {
  const opening = pickOpening(session.lines.map((line) => ({ ...line, spoken: lineText(line) })))
  const openingLine = session.lines.find((line) => line.id === opening?.id)
  const [items, setItems] = useState<ChatItem[]>(
    openingLine ? [{ id: 0, who: 'line', line: openingLine }] : [],
  )
  const [history, setHistory] = useState<TutorHistoryItem[]>([])
  const [phase, setPhase] = useState<Phase>(openingLine ? 'typing' : 'unavailable')
  const [tip, setTip] = useState<TutorTip | undefined>()
  const [reply, setReply] = useState('')
  const [status, setStatus] = useState('')
  const [dialogueOpen, setDialogueOpen] = useState(false)
  const [voiceOpen, setVoiceOpen] = useState(false)
  const [voiceReady, setVoiceReady] = useState(initial.voiceForTutor)
  const [recording, setRecording] = useState<'idle' | 'recording' | 'working'>('idle')
  const recorder = useRef<RecorderHandle | null>(null)
  const sending = useRef(false)
  const lastOtso = useRef<HTMLDivElement>(null)
  const field = useRef<HTMLInputElement>(null)
  const micButton = useRef<HTMLButtonElement>(null)
  const fieldId = useId()
  const dialogueTitle = useId()
  const voiceTitle = useId()
  const turnsDone = history.length
  const hasAi = items.some((item) => item.who === 'ai')
  const canSpeak = initial.speech && recordingSupported()

  // When Otso answers, focus moves to his line, so a screen reader reads it next (job 14 lesson).
  const otsoCount = items.filter((item) => item.who !== 'you').length
  useEffect(() => {
    if (otsoCount > 1) lastOtso.current?.focus()
  }, [otsoCount])

  useEffect(
    () => () => {
      recorder.current?.cancel()
    },
    [],
  )

  async function send(event?: SyntheticEvent) {
    event?.preventDefault()
    const text = reply.trim()
    if (sending.current || phase !== 'typing' || text === '') return
    sending.current = true
    setPhase('sending')
    setStatus('Otso is answering.')
    const nextId = items.length
    setItems((now) => [...now, { id: nextId, who: 'you', text }])
    setReply('')
    const result = await sendTurn(session.session.id, text, history)
    sending.current = false
    if (result.kind === 'signed_out') {
      window.location.replace(PATHS.home)
      return
    }
    if (result.kind === 'cap') {
      setPhase('cap')
      setStatus(OTSO_CAP)
      return
    }
    if (result.kind === 'unavailable') {
      setPhase('unavailable')
      setStatus(OTSO_UNAVAILABLE)
      return
    }
    const { otso, closing } = result.answer
    let shown: ChatItem
    let otsoText = ''
    if (otso.kind === 'ai') {
      shown = {
        id: nextId + 1,
        who: 'ai',
        text: otso.text,
        words: otso.words,
        ...(otso.meaning ? { meaning: otso.meaning } : {}),
      }
      otsoText = otso.text
    } else if (otso.kind === 'line') {
      const line = session.lines.find((l) => l.id === otso.lineId)
      shown = line ? { id: nextId + 1, who: 'line', line } : { id: nextId + 1, who: 'end' }
      otsoText = otso.text
    } else {
      shown = { id: nextId + 1, who: 'end' }
    }
    setItems((now) => [...now, shown])
    setHistory((now) => [...now, { you: text, otso: otsoText }])
    if (closing || shown.who === 'end') {
      setTip(result.answer.tip)
      setPhase('closed')
      setStatus('Otso answered. The chat is finished.')
    } else {
      setPhase('typing')
      setStatus('Otso answered.')
    }
  }

  function typeLetter(letter: string) {
    const input = field.current
    if (!input || phase !== 'typing') return
    const start = input.selectionStart ?? reply.length
    const end = input.selectionEnd ?? reply.length
    const next = reply.slice(0, start) + letter + reply.slice(end)
    if (next.length > MAX_TUTOR_REPLY) return
    setReply(next)
    restoreCaretAfterLetter(input, next, start + letter.length)
  }

  async function startSpeaking() {
    if (!voiceReady) {
      setVoiceOpen(true)
      return
    }
    try {
      recorder.current = await startRecording({
        onTick: () => undefined,
        onAutoStop: (result) => void finishSpeaking(result),
        onInterrupted: () => {
          recorder.current = null
          setRecording('idle')
        },
      })
      setRecording('recording')
      setStatus('Listening. Tap again when you have finished.')
    } catch {
      setStatus('The microphone could not start. You can type your answer.')
    }
  }

  async function finishSpeaking(result?: ReturnType<RecorderHandle['stop']>) {
    const handle = recorder.current
    recorder.current = null
    setRecording('working')
    setStatus('Turning your answer into text.')
    try {
      const recordingDone = await (result ?? handle?.stop())
      if (!recordingDone) throw new Error('no recording')
      const heard = await transcribe(session.session.id, recordingDone.wav)
      if (heard.kind === 'heard') {
        setReply(heard.text.slice(0, MAX_TUTOR_REPLY))
        setStatus('Check the text, then send it.')
        field.current?.focus()
      } else if (heard.kind === 'not_heard') {
        setStatus('Otso did not catch that. Try again, or type your answer.')
      } else if (heard.kind === 'no_voice_consent') {
        setVoiceReady(false)
        setVoiceOpen(true)
        setStatus('')
      } else if (heard.kind === 'too_many') {
        setStatus('You have recorded a lot in the last few minutes. Type your answer for now.')
      } else {
        setStatus('Your answer could not be turned into text. You can type it.')
      }
    } catch {
      setStatus('Your answer could not be turned into text. You can type it.')
    } finally {
      setRecording('idle')
    }
  }

  const closed = phase === 'closed'
  const stopped = phase === 'cap' || phase === 'unavailable'
  const counter = `${String(Math.min(turnsDone + 1, TUTOR_TURNS))} of ${String(TUTOR_TURNS)}`

  const composer = (
    <form className={styles.composer} onSubmit={(event) => void send(event)} noValidate>
      <div className={styles.composerRow}>
        <label htmlFor={fieldId} className={styles.hidden}>
          Your reply
        </label>
        <input
          ref={field}
          id={fieldId}
          className={styles.field}
          type="text"
          lang="fi"
          value={reply}
          maxLength={MAX_TUTOR_REPLY}
          placeholder="Type in Finnish…"
          disabled={phase !== 'typing' || recording !== 'idle'}
          autoCapitalize="off"
          autoCorrect="off"
          spellCheck={false}
          autoComplete="off"
          enterKeyHint="send"
          onChange={(event) => {
            setReply(event.target.value)
          }}
        />
        {canSpeak && reply.trim() === '' ? (
          <button
            ref={micButton}
            type="button"
            className={
              recording === 'recording'
                ? `${styles.round} ${styles.roundRecording}`
                : `${styles.round} ${styles.roundMic}`
            }
            aria-label={recording === 'recording' ? 'Stop recording' : 'Say your answer'}
            disabled={phase !== 'typing' || recording === 'working'}
            onClick={() => {
              if (recording === 'recording') void finishSpeaking()
              else void startSpeaking()
            }}
          >
            {recording === 'recording' ? <StopIcon /> : <MicIcon />}
          </button>
        ) : (
          <button
            type="submit"
            className={`${styles.round} ${styles.roundSend}`}
            aria-label="Send"
            disabled={phase !== 'typing' || reply.trim() === ''}
          >
            <SendIcon />
          </button>
        )}
      </div>
      <div className={styles.letters}>
        {(['ä', 'ö'] as const).map((letter) => (
          <button
            key={letter}
            type="button"
            className={styles.letter}
            aria-label={`Type ${letter}`}
            disabled={phase !== 'typing'}
            onMouseDown={(event) => {
              event.preventDefault()
            }}
            onClick={() => {
              typeLetter(letter)
            }}
          >
            <span lang="fi">{letter}</span>
          </button>
        ))}
      </div>
    </form>
  )

  const actions: ReactNode =
    closed || stopped ? (
      <>
        {stopped && <StatusLine tone="problem">{status}</StatusLine>}
        <Button block onClick={() => void onDone()}>
          Continue
        </Button>
      </>
    ) : (
      <>
        <StatusLine visuallyHidden>{status || 'Otso is waiting for your answer.'}</StatusLine>
        {composer}
      </>
    )

  const firstOtsoId = items.find((item) => item.who !== 'you')?.id
  return (
    <SessionFrame
      step={frame.step}
      steps={frame.steps}
      index={frame.index}
      progress={closed ? 1 : turnsDone / TUTOR_TURNS}
      leaveHref={PATHS.home}
      actions={actions}
    >
      <main className={styles.main}>
        <div className={styles.heading}>
          <h1 className={styles.title}>{closed ? TUTOR_DONE : TUTOR_TITLE}</h1>
          {!closed && <p className={styles.sub}>{TUTOR_SUB}</p>}
        </div>
        <div className={styles.chat}>
          {items.map((item, index) => {
            const last = index === items.length - 1 && item.who !== 'you'
            if (item.who === 'you') {
              return (
                <p key={item.id} className={styles.you} lang="fi">
                  <span className={styles.hidden}>You: </span>
                  {item.text}
                </p>
              )
            }
            const face = item.id === firstOtsoId
            return (
              <div key={item.id} className={styles.otsoTurn}>
                {face && <OtsoName face />}
                <div
                  ref={last ? lastOtso : undefined}
                  tabIndex={last ? -1 : undefined}
                  className={styles.otso}
                  aria-label={face ? undefined : item.who === 'ai' ? 'Otso, AI' : 'Otso'}
                  role="group"
                >
                  {item.who === 'line' && <ApprovedLine line={item.line} />}
                  {item.who === 'ai' && (
                    <>
                      <FinnishLine
                        only="spoken"
                        spoken={aiLineWords(item.words, session.lines)}
                        written={[]}
                        cardAudioWhat={LINE_AUDIO}
                        cardAudioCaption={CARD_AUDIO_CAPTION}
                      />
                      {item.meaning && <p className={styles.english}>{item.meaning}</p>}
                    </>
                  )}
                  {item.who === 'end' && <p className={styles.english}>{OTSO_ENDS}</p>}
                </div>
              </div>
            )
          })}
          {phase === 'sending' && (
            <p className={styles.waiting} aria-hidden="true">
              Otso is answering
            </p>
          )}
          {!closed && !stopped && (
            <p className={styles.tag}>
              {counter}
              {hasAi && ` · ${AI_NOTE}`}
            </p>
          )}
          {closed && hasAi && <p className={styles.tag}>{AI_NOTE}</p>}
          {closed && tip && <TipBox tip={tip} />}
        </div>
        {!closed && !stopped && (
          <div className={styles.quietRow}>
            <Button
              variant="quiet"
              onClick={() => {
                setDialogueOpen(true)
              }}
            >
              Look at today&apos;s dialogue
            </Button>
            <Button variant="quiet" onClick={() => void onDone()}>
              Stop here
            </Button>
          </div>
        )}
      </main>
      <Sheet
        open={dialogueOpen}
        onClose={() => {
          setDialogueOpen(false)
        }}
        labelledBy={dialogueTitle}
      >
        <h2 id={dialogueTitle} className={styles.sheetTitle}>
          Today&apos;s dialogue
        </h2>
        <div className={styles.sheetLines}>
          {session.lines.map((line) => (
            <div key={line.id} className={styles.sheetLine}>
              <p className={styles.speaker}>{line.speaker}</p>
              <ApprovedLine line={line} />
            </div>
          ))}
        </div>
        <Button
          variant="secondary"
          block
          arrow={false}
          onClick={() => {
            setDialogueOpen(false)
          }}
        >
          Close
        </Button>
      </Sheet>
      <Sheet
        open={voiceOpen}
        onClose={() => {
          setVoiceOpen(false)
        }}
        labelledBy={voiceTitle}
        returnFocus={micButton}
      >
        <div className={styles.sheetBody}>
          <h2 id={voiceTitle} className={styles.sheetTitle}>
            {VOICE_TITLE}
          </h2>
          <p className={styles.cardText}>{VOICE_TEXT}</p>
          <Button
            block
            onClick={() => {
              void chooseVoice('turn_on').then((loaded) => {
                setVoiceOpen(false)
                if (loaded.kind === 'ok') {
                  setVoiceReady(true)
                  setStatus('Spoken answers are on. Tap the microphone to answer.')
                } else {
                  setStatus('Spoken answers could not be turned on. You can type your answer.')
                }
              })
            }}
          >
            Turn on
          </Button>
          <Button
            variant="quiet"
            onClick={() => {
              setVoiceOpen(false)
            }}
          >
            Not now
          </Button>
        </div>
      </Sheet>
    </SessionFrame>
  )
}

/** An approved line in Otso's bubble: the spoken line with its word cards and audio, and its English. */
function ApprovedLine({ line }: { line: SessionLine }) {
  return (
    <>
      <FinnishLine
        only="spoken"
        spoken={lineWords(line.spoken, line)}
        written={[]}
        spokenControl={<PlayControl src={line.spokenAudio} what={LINE_AUDIO.spoken} size="small" />}
        cardAudioWhat={LINE_AUDIO}
        cardAudioCaption={CARD_AUDIO_CAPTION}
      />
      <p className={styles.english}>{line.gloss}</p>
    </>
  )
}

/** The tip: one approved line, peach, with its audio and English (statement 10). */
function TipBox({ tip }: { tip: TutorTip }) {
  return (
    <section className={styles.tip} aria-label="One tip">
      <p className={styles.tipLead}>One tip. A line that may help next time.</p>
      <div className={styles.tipLine}>
        <p className={styles.tipFinnish} lang="fi">
          {tip.spoken}
        </p>
        <PlayControl src={tip.spokenAudio} what="the tip line" size="small" />
      </div>
      <p className={styles.tipEnglish}>{tip.gloss}</p>
    </section>
  )
}

function SendIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" className={styles.icon}>
      <path d="M5 12h13M13 6l6 6-6 6" />
    </svg>
  )
}

function StopIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" className={styles.icon}>
      <rect x="7" y="7" width="10" height="10" rx="2" />
    </svg>
  )
}
