import { useEffect, useId, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { Wordmark } from '../components/Wordmark.tsx'
import { callApi, isRecord } from '../lib/api.ts'
import {
  FEEDBACK_LIMIT_TEXT,
  MAX_FEEDBACK_CHARS,
  feedbackLength,
  isFeedbackScreen,
  type FeedbackScreen,
} from '../lib/feedback-types.ts'
import styles from './Account.module.css'
import own from './Feedback.module.css'

// The feedback page, at /feedback (factory/jobs/14-analytics/spec.md, "Done
// when" 19 and 22). Reached only by a quiet "Send feedback" link from the
// account page, the finish screen or the front door; the loop gains no step.
// The link says which screen it came from (?from=), and that is all that is
// stored with the message besides the time. Needs an account on this device.

export const FEEDBACK_INTRO =
  'Tell us what worked, what did not, or what broke. Please do not include personal details.'
export const FEEDBACK_SENT = 'Thank you. Your message is sent.'
export const FEEDBACK_NO_ACCOUNT = 'Start your first session, then you can send feedback.'
const LOADING = 'Loading.'
const NOT_LOADED = 'This page could not be loaded. Check your internet connection, then try again.'
const EMPTY = 'Please write your message first.'
const TOO_LONG = 'Please keep your message to 1,000 characters.'
const NOT_SENT = 'Your message was not sent. Check your internet connection, then try again.'

type View = 'loading' | 'problem' | 'none' | 'form' | 'sent'

function screenFrom(search: string): FeedbackScreen {
  const from = new URLSearchParams(search).get('from')
  return isFeedbackScreen(from) ? from : 'account'
}

const BACK: Record<FeedbackScreen, { href: string; text: string }> = {
  front_door: { href: '/', text: 'Back to the start' },
  account: { href: '/account', text: 'Back to your account' },
  finish: { href: '/', text: 'Back to the start' },
}

export function FeedbackPage() {
  const [view, setView] = useState<View>('loading')
  const [message, setMessage] = useState('')
  const [status, setStatus] = useState<{ text: string; tone: StatusTone }>({ text: '', tone: 'neutral' })
  const [sending, setSending] = useState(false)
  const screen = screenFrom(window.location.search)
  const firstLook = useRef<Promise<View> | null>(null)
  const field = useRef<HTMLTextAreaElement>(null)
  const id = useId()
  const countId = `${id}-count`

  useEffect(() => {
    let active = true
    firstLook.current ??= callApi('/api/me', 'GET').then((answer): View => {
      if (answer?.status === 401) return 'none'
      if (answer?.status !== 200 || !isRecord(answer.body)) return 'problem'
      return answer.body.kind === 'guest' || answer.body.kind === 'email' ? 'form' : 'none'
    })
    void firstLook.current.then((next) => {
      if (active) setView(next)
    })
    return () => {
      active = false
    }
  }, [])

  const length = feedbackLength(message.trim())

  async function send() {
    // A second tap or Enter while sending would store the message twice.
    if (sending) return
    if (length === 0) {
      setStatus({ text: EMPTY, tone: 'gentle' })
      field.current?.focus()
      return
    }
    if (length > MAX_FEEDBACK_CHARS) {
      setStatus({ text: TOO_LONG, tone: 'gentle' })
      field.current?.focus()
      return
    }
    setSending(true)
    setStatus({ text: '', tone: 'neutral' })
    const answer = await callApi('/api/feedback', 'POST', { screen, message })
    setSending(false)
    if (answer?.status === 201) {
      setMessage('')
      setView('sent')
      return
    }
    if (answer?.status === 401) {
      setView('none')
      return
    }
    if (answer?.status === 429) setStatus({ text: FEEDBACK_LIMIT_TEXT, tone: 'gentle' })
    else if (answer?.status === 400) setStatus({ text: TOO_LONG, tone: 'gentle' })
    else setStatus({ text: NOT_SENT, tone: 'problem' })
  }

  const back = BACK[screen]

  return (
    <main className={styles.page}>
      <div className={styles.top}>
        <Wordmark height={36} />
      </div>
      <div className={styles.intro}>
        <h1 className={styles.title}>Send feedback</h1>
        {view === 'form' && <p className={styles.text}>{FEEDBACK_INTRO}</p>}
        {view === 'none' && <p className={styles.text}>{FEEDBACK_NO_ACCOUNT}</p>}
      </div>

      {view === 'form' && (
        <form
          className={styles.form}
          noValidate
          onSubmit={(event) => {
            event.preventDefault()
            void send()
          }}
        >
          <div className={own.field}>
            <label htmlFor={id} className={own.label}>
              Your message
            </label>
            <textarea
              ref={field}
              id={id}
              className={own.textarea}
              rows={6}
              maxLength={MAX_FEEDBACK_CHARS}
              aria-describedby={countId}
              value={message}
              onChange={(event) => {
                setMessage(event.target.value)
              }}
            />
            <p id={countId} className={own.count}>
              {length.toLocaleString('en-GB')} of 1,000 characters
            </p>
          </div>
          <div className={styles.actions}>
            <Button type="submit" block busy={sending} busyLabel="Sending your message.">
              Send
            </Button>
            <StatusLine tone={status.tone}>{status.text}</StatusLine>
          </div>
        </form>
      )}

      {view === 'sent' && <StatusLine tone="neutral">{FEEDBACK_SENT}</StatusLine>}
      {view === 'loading' && <StatusLine tone="neutral">{LOADING}</StatusLine>}
      {view === 'problem' && <StatusLine tone="problem">{NOT_LOADED}</StatusLine>}

      <ul className={styles.links}>
        {view === 'none' ? (
          <li>
            <a className={styles.link} href="/">
              Go to the front door
            </a>
          </li>
        ) : (
          <li>
            <a className={styles.link} href={back.href}>
              {back.text}
            </a>
          </li>
        )}
      </ul>
    </main>
  )
}
