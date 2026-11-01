import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { PageFrame } from '../components/PageFrame.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { leaveWith } from '../lib/account-notice.ts'
import { callApi, isRecord } from '../lib/api.ts'
import { PATHS } from '../lib/app-paths.ts'
import { downloadMyData } from '../lib/download.ts'
import { loadRoad } from '../lib/road-data.ts'
import { accountLetter, currentIndex } from '../lib/road-state.ts'
import type { RoadStop } from '../lib/road-types.ts'
import { parseVoiceAnswer } from '../lib/voice-api.ts'
import styles from './Account.module.css'

// The account page, at /account (factory/jobs/11-accounts/spec.md, "Done
// when" 2, 14 and 18; redrawn in job 19-redesign, statement 34 and 37): a
// profile page. A large avatar with the letter, the name line ("Guest" and
// "Saved on this device", or the email and "Saved to your email"), a "Your
// journey" panel from the stop data, and one settings panel with four rows:
// Speaking feedback (On or Off, opens Voice settings), Download my data,
// Privacy notice and Send feedback. A guest sees a peach note "Add your email to
// keep your progress." with an "Add" button, and has no Sign out. No counts of
// mistakes, scores or streaks.

export const NO_ACCOUNT = 'There is no account on this device.'
export const ADD_NOTE = 'Add your email to keep your progress.'
const LOADING = 'Loading your account.'
const NOT_LOADED = 'Your account could not be loaded. Check your internet connection, then try again.'
const PREPARING = 'Preparing your file.'
const READY = 'Your file is ready.'
const NOT_PREPARED = 'Your file could not be prepared. Check your internet connection, then try again.'
const NOT_SIGNED_OUT = 'You were not signed out. Check your internet connection, then try again.'

type View = { kind: 'loading' | 'problem' | 'none' | 'guest' } | { kind: 'email'; email: string }

function viewFrom(status: number | undefined, body: unknown): View {
  if (status === 401) return { kind: 'none' }
  if (status !== 200 || !isRecord(body)) return { kind: 'problem' }
  if (body.kind === 'guest') return { kind: 'guest' }
  if (body.kind === 'email' && typeof body.email === 'string') return { kind: 'email', email: body.email }
  if (body.kind === 'none') return { kind: 'none' }
  return { kind: 'problem' }
}

function Chevron() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" className={styles.chevron}>
      <path d="M9.5 5.5L16 12l-6.5 6.5" />
    </svg>
  )
}

function Journey({ stops }: { stops: readonly RoadStop[] }) {
  const index = currentIndex(stops)
  const stop = stops.at(index)
  if (!stop) return null
  const share = Math.round(((index + stop.lessonsDone / stop.lessons) / stops.length) * 100)
  return (
    <section className={styles.panel} aria-label="Your journey">
      <div className={styles.panelHead}>
        <span className={styles.quiet}>Your journey</span>
        <span className={styles.stopCount}>
          Stop {stop.number} of {stops.length}
        </span>
      </div>
      <div
        className={styles.journeyBar}
        role="progressbar"
        aria-label="Your journey to A1"
        aria-valuemin={0}
        aria-valuemax={100}
        aria-valuenow={share}
      >
        <span className={styles.journeyFill} style={{ width: `${String(share)}%` }} />
      </div>
      <div className={styles.panelHead}>
        <span className={styles.quiet}>Now: {stop.name}</span>
        <span className={styles.level}>A1</span>
      </div>
    </section>
  )
}

export function AccountPage() {
  const [view, setView] = useState<View>({ kind: 'loading' })
  const [status, setStatus] = useState<{ text: string; tone: StatusTone }>({ text: '', tone: 'neutral' })
  const [busy, setBusy] = useState<'download' | 'sign-out' | null>(null)
  const [stops, setStops] = useState<RoadStop[] | null>(null)
  const [voiceOn, setVoiceOn] = useState<boolean | null>(null)
  const [fileReady, setFileReady] = useState(false)
  const firstLook = useRef<Promise<View> | null>(null)

  useEffect(() => {
    let active = true
    firstLook.current ??= callApi('/api/me', 'GET').then((answer) => viewFrom(answer?.status, answer?.body))
    void firstLook.current.then((next) => {
      if (!active) return
      setView(next)
      if (next.kind !== 'guest' && next.kind !== 'email') return
      // The journey panel and the speaking feedback value read what the account already holds.
      void loadRoad().then((road) => {
        if (active && road) setStops(road.stops)
      })
      void callApi('/api/voice', 'GET').then((answer) => {
        const voice = answer?.status === 200 ? parseVoiceAnswer(answer.body) : null
        if (active && voice) setVoiceOn(voice.processing === 'granted')
      })
    })
    return () => {
      active = false
    }
  }, [])

  async function download() {
    setBusy('download')
    setStatus({ text: PREPARING, tone: 'neutral' })
    const result = await downloadMyData()
    setBusy(null)
    if (result === 'signed_out') {
      setView({ kind: 'none' })
      setStatus({ text: '', tone: 'neutral' })
      return
    }
    if (result === 'ready') {
      setStatus({ text: READY, tone: 'neutral' })
      setFileReady(true)
      return
    }
    setStatus({ text: NOT_PREPARED, tone: 'problem' })
  }

  async function signOut() {
    setBusy('sign-out')
    const answer = await callApi('/api/sign-out', 'POST')
    if (answer?.status === 200 || answer?.status === 401) {
      leaveWith('signed-out')
      return
    }
    setBusy(null)
    setStatus({ text: NOT_SIGNED_OUT, tone: 'problem' })
  }

  const signedIn = view.kind === 'guest' || view.kind === 'email'

  // The file is ready: shown in place, with no address of its own (statement 37).
  if (fileReady && signedIn) {
    return (
      <PageFrame
        back={PATHS.account}
        backLabel="Back to your account"
        actions={
          <Button block busy={busy === 'download'} busyLabel={PREPARING} onClick={() => void download()}>
            Download
          </Button>
        }
      >
        <div className={styles.ready}>
          <div className={styles.orb} aria-hidden="true">
            <svg viewBox="0 0 24 24" focusable="false">
              <path d="M5 12.5l4.5 4.5L19 7.5" />
            </svg>
          </div>
          <h1 className={styles.readyTitle}>{READY}</h1>
          <p className={styles.readyText}>Everything we keep about you, in one file.</p>
          {/* The title says the file is ready; this line speaks only when something else happens. */}
          <StatusLine tone={status.tone}>{status.text === READY ? '' : status.text}</StatusLine>
        </div>
      </PageFrame>
    )
  }

  const letter = view.kind === 'guest' ? 'G' : view.kind === 'email' ? accountLetter('email', view.email) : ''

  return (
    <PageFrame back={PATHS.home} backLabel="Back to the road">
      <h1 className={styles.hidden}>Your account</h1>
      {signedIn && (
        <div className={styles.profile}>
          <div className={styles.avatar} aria-hidden="true">
            {letter}
          </div>
          <p className={styles.name}>{view.kind === 'email' ? view.email : 'Guest'}</p>
          <p className={styles.saved}>
            {view.kind === 'email' ? 'Saved to your email' : 'Saved on this device'}
          </p>
        </div>
      )}
      {view.kind === 'none' && <p className={styles.text}>{NO_ACCOUNT}</p>}
      {signedIn && stops && <Journey stops={stops} />}
      {view.kind === 'guest' && (
        <div className={styles.addNote}>
          <p className={styles.addText}>{ADD_NOTE}</p>
          <Button
            variant="secondary"
            aria-label="Add your email"
            onClick={() => {
              window.location.assign(PATHS.accountEmail)
            }}
          >
            Add
          </Button>
        </div>
      )}
      {signedIn && (
        <ul className={styles.settings}>
          <li>
            <a className={styles.row} href={PATHS.voice}>
              <span>Speaking feedback</span>
              <span className={styles.rowEnd}>
                {voiceOn !== null && <span className={styles.value}>{voiceOn ? 'On' : 'Off'}</span>}
                <Chevron />
              </span>
            </a>
          </li>
          <li>
            <button
              type="button"
              className={styles.row}
              aria-busy={busy === 'download' || undefined}
              onClick={() => {
                if (busy === null) void download()
              }}
            >
              <span>Download my data</span>
              <span className={styles.rowEnd}>
                <Chevron />
              </span>
            </button>
          </li>
          <li>
            <a className={styles.row} href={PATHS.privacy}>
              <span>Privacy notice</span>
              <span className={styles.rowEnd}>
                <Chevron />
              </span>
            </a>
          </li>
          <li>
            <a className={styles.row} href={`${PATHS.feedback}?from=account`}>
              <span>Send feedback</span>
              <span className={styles.rowEnd}>
                <Chevron />
              </span>
            </a>
          </li>
        </ul>
      )}
      {view.kind === 'none' && (
        <>
          <Button
            block
            onClick={() => {
              window.location.assign(PATHS.signIn)
            }}
          >
            Sign in with your email
          </Button>
          <a className={styles.smallLink} href={PATHS.privacy}>
            Privacy notice
          </a>
        </>
      )}
      <StatusLine tone={view.kind === 'problem' ? 'problem' : status.tone}>
        {view.kind === 'loading' ? LOADING : view.kind === 'problem' ? NOT_LOADED : status.text}
      </StatusLine>
      {signedIn && (
        <div className={styles.small}>
          {view.kind === 'email' && (
            <Button
              variant="quiet"
              busy={busy === 'sign-out'}
              busyLabel="Signing you out."
              onClick={() => void signOut()}
            >
              Sign out
            </Button>
          )}
          <a className={styles.deleteLink} href={PATHS.accountDelete}>
            Delete my account
          </a>
        </div>
      )}
    </PageFrame>
  )
}
