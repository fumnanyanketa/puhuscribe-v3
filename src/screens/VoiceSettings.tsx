import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { PlayControl } from '../components/PlayControl.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import type { VoiceAnswer } from '../lib/speech-types.ts'
import { voiceNotice } from '../lib/voice-consent.ts'
import { NOT_AVAILABLE, chooseVoice, deleteKept, loadVoice, type VoiceLoad } from '../lib/voice-api.ts'
import { VoiceConsent } from './VoiceConsent.tsx'
import voice from './Voice.module.css'

// Voice settings, at /voice (factory/jobs/10-speaking-feedback/spec.md,
// "Done when" 4 and 19). Both choices with one press each to change, and the
// learner's kept recordings, newest first, each with Play and Delete.
// Turning speaking feedback on here shows the same consent text as Say it.
// Turning either choice off deletes kept recordings in the database, in the
// same transaction as the choice.

const LOADING = 'Loading your voice settings.'
const NOT_LOADED = 'Your voice settings could not be loaded. Check your internet connection, then try again.'
const NOT_SAVED = 'Your change was not saved. Check your internet connection, then try again.'

const DATE = new Intl.DateTimeFormat('en-GB', { day: 'numeric', month: 'long', year: 'numeric' })

function dateOf(iso: string): string {
  const date = new Date(iso)
  return Number.isNaN(date.getTime()) ? '' : DATE.format(date)
}

export function VoiceSettings() {
  const [state, setState] = useState<VoiceAnswer | null>(null)
  const [message, setMessage] = useState<{ tone: StatusTone; text: string }>({
    tone: 'neutral',
    text: LOADING,
  })
  const [asking, setAsking] = useState(false)
  const [keep, setKeep] = useState(false)
  const [busy, setBusy] = useState<string | null>(null)
  const firstLoad = useRef<Promise<VoiceLoad> | null>(null)

  function show(load: VoiceLoad, done: string, failed: string) {
    if (load.kind === 'signed_out') {
      window.location.replace('/')
      return
    }
    if (load.kind === 'failed') {
      setMessage({ tone: 'problem', text: failed })
      return
    }
    setState(load.voice)
    setMessage({ tone: 'neutral', text: done })
  }

  useEffect(() => {
    let active = true
    firstLoad.current ??= loadVoice()
    void firstLoad.current.then((load) => {
      if (active) show(load, 'Your voice settings are shown below.', NOT_LOADED)
    })
    return () => {
      active = false
    }
  }, [])

  async function change(id: string, run: () => Promise<VoiceLoad>, done: string) {
    setBusy(id)
    const load = await run()
    setBusy(null)
    show(load, done, NOT_SAVED)
  }

  const notice = voiceNotice(state?.region ?? null)
  const on = state?.processing === 'granted'

  return (
    <main className={voice.page}>
      <h1 className={voice.title}>Voice settings</h1>
      <StatusLine tone={message.tone}>{message.text}</StatusLine>
      {state && (
        <>
          <section className={voice.section} aria-labelledby="speaking-heading">
            <h2 id="speaking-heading" className={voice.sectionTitle}>
              Speaking feedback
            </h2>
            <p className={voice.text}>
              {on
                ? 'On. Your recordings are checked and you get a short hint for each line.'
                : 'Off. Nothing is recorded. You can still say each line out loud.'}
            </p>
            {!state.available && <p className={voice.text}>{NOT_AVAILABLE}</p>}
            {on && (
              <Button
                variant="secondary"
                busy={busy === 'off'}
                busyLabel="Turning off speaking feedback."
                onClick={() => void change('off', () => chooseVoice('turn_off'), 'Speaking feedback is off.')}
              >
                Turn off speaking feedback
              </Button>
            )}
            {!on && !asking && state.available && (
              <Button
                variant="secondary"
                onClick={() => {
                  setKeep(false)
                  setAsking(true)
                }}
              >
                {notice.turnOn}
              </Button>
            )}
            {!on && asking && (
              <>
                <VoiceConsent region={state.region} keep={keep} onKeepChange={setKeep} headingLevel={2} />
                <div className={voice.buttons}>
                  <Button
                    block
                    busy={busy === 'on'}
                    busyLabel="Saving your choice."
                    onClick={() =>
                      void change(
                        'on',
                        async () => {
                          const load = await chooseVoice('turn_on', keep)
                          if (load.kind === 'ok') setAsking(false)
                          return load
                        },
                        'Speaking feedback is on.',
                      )
                    }
                  >
                    {notice.turnOn}
                  </Button>
                  <Button
                    block
                    variant="secondary"
                    onClick={() => {
                      setAsking(false)
                    }}
                  >
                    {notice.notNow}
                  </Button>
                </div>
              </>
            )}
          </section>

          <section className={voice.section} aria-labelledby="keep-heading">
            <h2 id="keep-heading" className={voice.sectionTitle}>
              Keep my recordings
            </h2>
            <p className={voice.text}>
              {state.retention
                ? 'On. We keep your first and latest try of each line for 90 days.'
                : 'Off. Your recordings are deleted as soon as your feedback is ready.'}
            </p>
            {on && (
              <Button
                variant="secondary"
                busy={busy === 'keep'}
                busyLabel="Saving your choice."
                onClick={() =>
                  void change(
                    'keep',
                    () => chooseVoice(state.retention ? 'keep_off' : 'keep_on'),
                    state.retention
                      ? 'Your recordings are no longer kept, and the kept ones are deleted.'
                      : 'Your recordings will be kept.',
                  )
                }
              >
                {state.retention ? 'Stop keeping my recordings' : 'Keep my recordings'}
              </Button>
            )}
            {!on && <p className={voice.quietText}>Turn on speaking feedback first.</p>}
          </section>

          <section className={voice.section} aria-labelledby="recordings-heading">
            <h2 id="recordings-heading" className={voice.sectionTitle}>
              My recordings
            </h2>
            {state.recordings.length === 0 ? (
              <p className={voice.text}>You have no kept recordings.</p>
            ) : (
              <>
                <ul className={voice.recordings}>
                  {state.recordings.map((row) => (
                    <li key={row.id} className={voice.recording} data-recording-id={row.id}>
                      {row.line && (
                        <p className={voice.text} lang="fi">
                          {row.line}
                        </p>
                      )}
                      <p className={voice.quietText}>
                        {row.slot === 'first' ? 'First try' : 'Latest try'}, {dateOf(row.createdAt)}.
                      </p>
                      <div className={voice.recordingControls}>
                        <PlayControl
                          src={`/api/voice/recordings/${row.id}`}
                          what="your recording"
                          size="small"
                        />
                        <Button
                          variant="secondary"
                          busy={busy === row.id}
                          busyLabel="Deleting the recording."
                          aria-label={`Delete this recording, ${row.slot === 'first' ? 'first try' : 'latest try'}`}
                          onClick={() =>
                            void change(row.id, () => deleteKept({ id: row.id }), 'The recording is deleted.')
                          }
                        >
                          Delete
                        </Button>
                      </div>
                    </li>
                  ))}
                </ul>
                <Button
                  variant="secondary"
                  busy={busy === 'all'}
                  busyLabel="Deleting all your recordings."
                  onClick={() =>
                    void change('all', () => deleteKept({ all: true }), 'All your recordings are deleted.')
                  }
                >
                  Delete all my recordings
                </Button>
              </>
            )}
          </section>
        </>
      )}
      <a className={voice.link} href="/">
        Back to the start
      </a>
    </main>
  )
}
