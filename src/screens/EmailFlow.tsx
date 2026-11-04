import { useEffect, useRef, useState, type SyntheticEvent } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { CodeField } from '../components/CodeField.tsx'
import { PageFrame } from '../components/PageFrame.tsx'
import { TextField } from '../components/TextField.tsx'
import { PATHS } from '../lib/app-paths.ts'
import { callApi, isRecord } from '../lib/api.ts'
import { cleanCode, cleanEmail } from '../lib/email-address.ts'
import styles from './Account.module.css'

// The email and code screens (factory/jobs/11-accounts/spec.md, "Done when"
// 4, 5, 8, 10 and 13). Two uses of the same screens:
// - "add", at /account/email: a guest adds an email to the same account.
// - "sign-in", at /sign-in: a device signs in to an existing email account.
// The answer to "Send code" is the same whatever the address, so the screens
// never say whether an address has an account (statement 9).

export const SENDS_CODE =
  'We send a 6 digit code to this address. We use your email only to send you sign in codes.'
export const TAKEN_WARNING =
  'If this email already has an Aleksi account, the code signs you in to that account instead. Your guest progress on this device is then deleted, because progress cannot be moved between accounts.'
export const GUEST_WARNING =
  'This device has a guest account. Signing in deletes its progress, because progress cannot be moved between accounts. To keep it, add your email to the guest account instead.'
// The same sentence for every address, so the screen never says which emails have accounts (owner's
// words, 4 November 2026, job signin-center).
export const SIGN_IN_SENT = 'You will receive a 6 digit code.'
export const SIGN_IN_NO_CODE =
  'No code after a few minutes? Check the address, or go back and start as a guest.'
export const CODE_WORKS = 'The code works for one hour.'
export const CHECK_EMAIL = 'Please check the email address.'
export const WRONG_CODE = 'That code did not work. Check the numbers and try again.'
export const TOO_MANY = 'Too many tries for now. Wait a few minutes, then try again.'
export const ADDED = 'Your email is added. Your progress is saved to your account.'
export const SWITCHED = 'You are signed in to your account. The guest progress from this device was deleted.'
export const SIGNED_IN = 'You are signed in to your account.'
const NOT_SENT = 'The code could not be sent. Check your internet connection, then try again.'
const NOT_CHECKED = 'The code could not be checked. Check your internet connection, then try again.'
const NEW_CODE_SENT = 'We sent a new code.'
const LOADING = 'Loading.'

const EMAIL_FORM = 'email-form'
const CODE_FORM = 'code-form'

/** Supabase sends one code per address per minute. */
const RESEND_AFTER_MS = 60_000

type Mode = 'add' | 'sign-in'
type Step = 'loading' | 'warn' | 'email' | 'code' | 'done'

interface Status {
  text: string
  tone: StatusTone
}

const QUIET: Status = { text: '', tone: 'neutral' }

/** "Send a new code in 0:45": the wait, read on the link itself (round 6). */
export function waitText(msLeft: number): string {
  const seconds = Math.max(0, Math.ceil(msLeft / 1000))
  return `${String(Math.floor(seconds / 60))}:${String(seconds % 60).padStart(2, '0')}`
}

export function EmailFlow({ mode }: { mode: Mode }) {
  // The owner's titles (job 19-redesign): "Create your account" (1 November 2026) and the drawing's
  // "Welcome back" for sign in (round 6).
  const heading = mode === 'add' ? 'Create your account' : 'Welcome back'
  const [step, setStep] = useState<Step>('loading')
  const [email, setEmail] = useState('')
  const [sentTo, setSentTo] = useState('')
  const [code, setCode] = useState('')
  const [status, setStatus] = useState<Status>(QUIET)
  const [busy, setBusy] = useState(false)
  const [canResend, setCanResend] = useState(false)
  // When a new code may be asked for, and the clock that counts down to it on the link.
  const [resendAt, setResendAt] = useState(0)
  const [now, setNow] = useState(() => Date.now())
  const [done, setDone] = useState('')
  const resendTimer = useRef<ReturnType<typeof setTimeout> | null>(null)
  const firstLook = useRef<Promise<Step | 'leave'> | null>(null)
  const emailField = useRef<HTMLInputElement>(null)
  const codeField = useRef<HTMLInputElement>(null)

  useEffect(() => {
    let active = true
    // Who is on this device decides the first screen: adding needs a guest;
    // signing in warns a guest first, and an email account has nothing to do here.
    firstLook.current ??= callApi('/api/me', 'GET').then((answer) => {
      const kind = answer?.status === 200 && isRecord(answer.body) ? answer.body.kind : 'none'
      if (mode === 'add') return kind === 'guest' ? 'email' : 'leave'
      if (kind === 'email') return 'leave'
      return kind === 'guest' ? 'warn' : 'email'
    })
    void firstLook.current.then((next) => {
      if (!active) return
      if (next === 'leave') window.location.replace(PATHS.account)
      else setStep(next)
    })
    return () => {
      active = false
    }
  }, [mode])

  useEffect(() => {
    if (step === 'email') emailField.current?.focus()
    if (step === 'code') codeField.current?.focus()
  }, [step])

  useEffect(
    () => () => {
      if (resendTimer.current) clearTimeout(resendTimer.current)
    },
    [],
  )

  // The link counts down once a second while it waits.
  useEffect(() => {
    if (canResend || resendAt === 0) return undefined
    const tick = setInterval(() => {
      setNow(Date.now())
    }, 1000)
    return () => {
      clearInterval(tick)
    }
  }, [canResend, resendAt])

  function startResendTimer() {
    setCanResend(false)
    const start = Date.now()
    setNow(start)
    setResendAt(start + RESEND_AFTER_MS)
    if (resendTimer.current) clearTimeout(resendTimer.current)
    resendTimer.current = setTimeout(() => {
      setCanResend(true)
    }, RESEND_AFTER_MS)
  }

  async function send(address: string): Promise<boolean> {
    const path = mode === 'add' ? '/api/account/email' : '/api/sign-in'
    const answer = await callApi(path, 'POST', { email: address })
    if (answer?.status === 200) return true
    if (answer?.status === 400) setStatus({ text: CHECK_EMAIL, tone: 'gentle' })
    else if (answer?.status === 401 || answer?.status === 409) window.location.replace(PATHS.account)
    else setStatus({ text: NOT_SENT, tone: 'problem' })
    return false
  }

  async function sendCode(event: SyntheticEvent) {
    event.preventDefault()
    if (busy) return
    const address = cleanEmail(email)
    if (!address) {
      setStatus({ text: CHECK_EMAIL, tone: 'gentle' })
      return
    }
    setBusy(true)
    setStatus(QUIET)
    const sent = await send(address)
    setBusy(false)
    if (!sent) return
    setSentTo(address)
    setCode('')
    setStep('code')
    startResendTimer()
  }

  async function resend() {
    if (busy || !canResend) return
    setBusy(true)
    const sent = await send(sentTo)
    setBusy(false)
    if (!sent) return
    setStatus({ text: NEW_CODE_SENT, tone: 'neutral' })
    startResendTimer()
  }

  async function confirm(event: SyntheticEvent) {
    event.preventDefault()
    if (busy) return
    const typed = cleanCode(code)
    if (!typed) {
      setStatus({ text: WRONG_CODE, tone: 'gentle' })
      return
    }
    setBusy(true)
    setStatus(QUIET)
    const path = mode === 'add' ? '/api/account/email/verify' : '/api/sign-in/verify'
    const answer = await callApi(path, 'POST', { email: sentTo, code: typed })
    setBusy(false)
    const result = answer?.status === 200 && isRecord(answer.body) ? answer.body.result : null
    if (result === 'added' || result === 'switched' || result === 'signed_in') {
      setDone(result === 'added' ? ADDED : result === 'switched' ? SWITCHED : SIGNED_IN)
      setStep('done')
      return
    }
    if (answer?.status === 400) setStatus({ text: WRONG_CODE, tone: 'gentle' })
    else if (answer?.status === 429) setStatus({ text: TOO_MANY, tone: 'gentle' })
    else if (answer?.status === 401 || answer?.status === 409) window.location.replace(PATHS.account)
    else setStatus({ text: NOT_CHECKED, tone: 'problem' })
  }

  function backToEmail() {
    setStatus(QUIET)
    setStep('email')
  }

  return (
    <PageFrame
      back={mode === 'add' ? PATHS.account : PATHS.home}
      backLabel={
        step === 'code'
          ? 'Use another email address'
          : mode === 'add'
            ? 'Back to your account'
            : 'Back to the road'
      }
      // On the code step the back arrow goes back to the email field, as the drawing's "Use another email address" did.
      onBack={step === 'code' ? backToEmail : undefined}
      actions={
        step === 'email' || step === 'code' ? (
          <>
            <StatusLine tone={status.tone}>{status.text}</StatusLine>
            {step === 'email' ? (
              <Button type="submit" form={EMAIL_FORM} block busy={busy} busyLabel="Sending the code.">
                Send code
              </Button>
            ) : (
              <Button
                type="submit"
                form={CODE_FORM}
                block
                busy={busy}
                busyLabel="Checking the code."
                disabled={cleanCode(code) === null}
              >
                Confirm
              </Button>
            )}
            {step === 'email' && mode === 'sign-in' && (
              <a className={styles.smallLink} href={PATHS.home}>
                Start as a guest instead
              </a>
            )}
            <a className={styles.smallLink} href={PATHS.privacy}>
              Privacy notice
            </a>
          </>
        ) : undefined
      }
    >
      {step === 'loading' && (
        <div className={styles.intro}>
          <h1 className={styles.title}>{heading}</h1>
          <StatusLine>{LOADING}</StatusLine>
        </div>
      )}

      {step === 'warn' && (
        <>
          <div className={styles.intro}>
            <h1 className={styles.title}>{heading}</h1>
            <p className={styles.text}>{GUEST_WARNING}</p>
          </div>
          <div className={styles.actions}>
            <Button
              block
              onClick={() => {
                setStep('email')
              }}
            >
              Sign in anyway
            </Button>
            <Button
              variant="secondary"
              block
              onClick={() => {
                window.location.assign(PATHS.account)
              }}
            >
              Go back
            </Button>
          </div>
        </>
      )}

      {step === 'email' && (
        <form id={EMAIL_FORM} className={styles.form} noValidate onSubmit={(event) => void sendCode(event)}>
          {/* Sign in centres its title, subtitle and the line under the field (owner, 4 November 2026). */}
          <div className={mode === 'sign-in' ? `${styles.intro} ${styles.introCentre}` : styles.intro}>
            <h1 className={styles.title}>{heading}</h1>
            {mode === 'sign-in' && <p className={styles.subtitle}>Enter your email for a code.</p>}
          </div>
          <div className={styles.fieldGroup}>
            <TextField
              ref={emailField}
              id="email"
              label="Email address"
              placeholder="Your email"
              type="email"
              autoComplete="email"
              inputMode="email"
              autoCapitalize="none"
              spellCheck={false}
              value={email}
              onChange={(event) => {
                setEmail(event.target.value)
              }}
            />
            {/* The protected sentences stay word for word, small and quiet under the field (round 6). */}
            <p className={mode === 'sign-in' ? styles.quietCentre : styles.quietText}>{SENDS_CODE}</p>
            {mode === 'add' && <p className={styles.quietText}>{TAKEN_WARNING}</p>}
          </div>
        </form>
      )}

      {step === 'code' && (
        <form id={CODE_FORM} className={styles.form} noValidate onSubmit={(event) => void confirm(event)}>
          {/* Both paths centre the code screen's title and subtitle, so they look alike. */}
          <div className={`${styles.intro} ${styles.introCentre}`}>
            <h1 className={styles.title}>Enter the code</h1>
            {mode === 'add' ? (
              <p className={styles.subtitle}>Sent to {sentTo}</p>
            ) : (
              <p className={styles.subtitle}>{SIGN_IN_SENT}</p>
            )}
          </div>
          <div className={styles.fieldGroup}>
            <CodeField ref={codeField} id="code" label="6 digit code" value={code} onChange={setCode} />
            <Button
              variant="quiet"
              className={styles.resend}
              disabled={!canResend}
              onClick={() => void resend()}
            >
              {canResend ? 'Send a new code' : `Send a new code in ${waitText(resendAt - now)}`}
            </Button>
            {mode === 'sign-in' && <p className={styles.quietCentre}>{SIGN_IN_NO_CODE}</p>}
            <p className={styles.quietCentre}>{CODE_WORKS}</p>
          </div>
        </form>
      )}

      {step === 'done' && (
        <>
          <div className={styles.intro}>
            <h1 className={styles.title}>{heading}</h1>
            <StatusLine>{done}</StatusLine>
          </div>
          <div className={styles.actions}>
            <Button
              block
              onClick={() => {
                window.location.assign(PATHS.home)
              }}
            >
              Continue
            </Button>
          </div>
        </>
      )}
    </PageFrame>
  )
}
