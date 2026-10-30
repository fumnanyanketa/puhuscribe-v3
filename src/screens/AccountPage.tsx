import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { Wordmark } from '../components/Wordmark.tsx'
import { leaveWith } from '../lib/account-notice.ts'
import { callApi, isRecord } from '../lib/api.ts'
import { downloadMyData } from '../lib/download.ts'
import styles from './Account.module.css'

// The account page, at /account (factory/jobs/11-accounts/spec.md, "Done
// when" 2, 14 and 18). It says what kind of account this device has and
// offers what fits it. No counts, scores or streaks, and no learning: the
// learner reaches it by a quiet link from the front door.

export const GUEST_TEXT =
  'You are using a guest account on this device. Add your email to keep your progress and use it on other devices.'
export const GUEST_CANNOT_SIGN_OUT =
  'A guest account cannot sign back in, so add your email before you leave.'
export const NO_ACCOUNT = 'There is no account on this device.'
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

export function AccountPage() {
  const [view, setView] = useState<View>({ kind: 'loading' })
  const [status, setStatus] = useState<{ text: string; tone: StatusTone }>({ text: '', tone: 'neutral' })
  const [busy, setBusy] = useState<'download' | 'sign-out' | null>(null)
  const firstLook = useRef<Promise<View> | null>(null)

  useEffect(() => {
    let active = true
    firstLook.current ??= callApi('/api/me', 'GET').then((answer) => viewFrom(answer?.status, answer?.body))
    void firstLook.current.then((next) => {
      if (active) setView(next)
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
    setStatus(result === 'ready' ? { text: READY, tone: 'neutral' } : { text: NOT_PREPARED, tone: 'problem' })
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

  return (
    <main className={styles.page}>
      <div className={styles.top}>
        <Wordmark height={36} />
      </div>
      <div className={styles.intro}>
        <h1 className={styles.title}>Your account</h1>
        {view.kind === 'guest' && <p className={styles.text}>{GUEST_TEXT}</p>}
        {view.kind === 'email' && <p className={styles.text}>You are signed in as {view.email}.</p>}
        {view.kind === 'none' && <p className={styles.text}>{NO_ACCOUNT}</p>}
      </div>

      <div className={styles.actions}>
        {view.kind === 'guest' && (
          <>
            <Button
              block
              onClick={() => {
                window.location.assign('/account/email')
              }}
            >
              Add your email
            </Button>
            <p className={styles.quietText}>{GUEST_CANNOT_SIGN_OUT}</p>
          </>
        )}
        {view.kind === 'email' && (
          <Button
            variant="secondary"
            block
            busy={busy === 'sign-out'}
            busyLabel="Signing you out."
            onClick={() => void signOut()}
          >
            Sign out
          </Button>
        )}
        {view.kind === 'none' && (
          <Button
            block
            onClick={() => {
              window.location.assign('/sign-in')
            }}
          >
            Sign in with your email
          </Button>
        )}
        {signedIn && (
          <Button
            variant="secondary"
            block
            busy={busy === 'download'}
            busyLabel={PREPARING}
            onClick={() => void download()}
          >
            Download my data
          </Button>
        )}
        <StatusLine tone={view.kind === 'problem' ? 'problem' : status.tone}>
          {view.kind === 'loading' ? LOADING : view.kind === 'problem' ? NOT_LOADED : status.text}
        </StatusLine>
      </div>

      <ul className={styles.links}>
        {signedIn && (
          <li>
            <a className={styles.link} href="/feedback?from=account">
              Send feedback
            </a>
          </li>
        )}
        {signedIn && (
          <li>
            <a className={styles.link} href="/account/delete">
              Delete my account
            </a>
          </li>
        )}
        <li>
          <a className={styles.link} href="/privacy">
            Privacy notice
          </a>
        </li>
        <li>
          <a className={styles.link} href="/">
            Back to the start
          </a>
        </li>
      </ul>
    </main>
  )
}
