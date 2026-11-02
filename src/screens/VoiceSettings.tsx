import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { PageFrame } from '../components/PageFrame.tsx'
import { PlayControl } from '../components/PlayControl.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { Switch } from '../components/Switch.tsx'
import { PATHS } from '../lib/app-paths.ts'
import type { VoiceAnswer } from '../lib/speech-types.ts'
import { voiceNotice } from '../lib/voice-consent.ts'
import { NOT_AVAILABLE, chooseVoice, deleteKept, loadVoice, type VoiceLoad } from '../lib/voice-api.ts'
import { ConsentSheet } from './ConsentSheet.tsx'
import voice from './Voice.module.css'

// Voice settings, at /voice (factory/jobs/10-speaking-feedback/spec.md, "Done
// when" 4 and 19; redrawn in job 19-redesign, statement 36). Two real switches,
// "Speaking feedback" and "Keep my recordings", one press changes each, and the
// learner's kept recordings, newest first, each with Play and Delete, and a
// danger text button "Delete my recordings". Turning speaking feedback on shows
// the consent sheet, as Say it does. Turning either choice off deletes kept
// recordings in the database, in the same transaction as the choice.

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
  const [busy, setBusy] = useState<string | null>(null)
  const firstLoad = useRef<Promise<VoiceLoad> | null>(null)
  // The switch that opens the consent sheet gets focus back when the sheet closes (a tap does not focus it in Safari).
  const speakingSwitch = useRef<HTMLButtonElement>(null)

  function show(load: VoiceLoad, done: string, failed: string) {
    if (load.kind === 'signed_out') {
      window.location.replace(PATHS.home)
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

  const on = state?.processing === 'granted'

  return (
    <PageFrame back={PATHS.account} backLabel="Back to your account" title="Voice settings">
      <StatusLine tone={message.tone}>{message.text}</StatusLine>
      {state && (
        <>
          <section className={voice.switches} aria-label="Your choices">
            <Switch
              ref={speakingSwitch}
              label="Speaking feedback"
              hint={
                on
                  ? 'On. Your recordings are checked and you get a short hint for each line.'
                  : 'Off. Nothing is recorded. You can still say each line out loud.'
              }
              checked={on}
              busy={busy === 'speaking'}
              busyLabel={on ? 'Turning off speaking feedback.' : 'Saving your choice.'}
              disabled={!on && !state.available}
              onChange={(next) => {
                if (next) setAsking(true)
                else void change('speaking', () => chooseVoice('turn_off'), 'Speaking feedback is off.')
              }}
            />
            {!state.available && <p className={voice.quietText}>{NOT_AVAILABLE}</p>}
            <Switch
              label="Keep my recordings"
              // The sentence the consent record is stamped with (src/lib/voice-consent.ts), read before the press.
              hint={`${state.retention ? 'On.' : 'Off.'} ${voiceNotice(state.region).keepBox}`}
              checked={state.retention}
              busy={busy === 'keep'}
              disabled={!on}
              onChange={(next) => {
                void change(
                  'keep',
                  () => chooseVoice(next ? 'keep_on' : 'keep_off'),
                  next
                    ? 'Your recordings will be kept.'
                    : 'Your recordings are no longer kept, and the kept ones are deleted.',
                )
              }}
            />
            {!on && <p className={voice.quietText}>Turn on speaking feedback first.</p>}
          </section>

          <section className={voice.section} aria-labelledby="recordings-heading">
            <h2 id="recordings-heading" className={voice.sectionTitle}>
              My recordings
            </h2>
            {state.recordings.length === 0 ? (
              <p className={voice.text}>You have no kept recordings.</p>
            ) : (
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
            )}
          </section>
        </>
      )}
      {state && state.recordings.length > 0 && (
        <Button
          variant="quiet"
          className={voice.danger}
          busy={busy === 'all'}
          busyLabel="Deleting all your recordings."
          onClick={() =>
            void change('all', () => deleteKept({ all: true }), 'All your recordings are deleted.')
          }
        >
          Delete all my recordings
        </Button>
      )}
      <ConsentSheet
        open={asking}
        returnFocus={speakingSwitch}
        region={state?.region ?? null}
        busy={busy === 'on'}
        onTurnOn={() =>
          void change(
            'on',
            async () => {
              const load = await chooseVoice('turn_on', false)
              if (load.kind === 'ok') setAsking(false)
              return load
            },
            'Speaking feedback is on.',
          )
        }
        onNotNow={() => {
          setAsking(false)
        }}
      />
    </PageFrame>
  )
}
