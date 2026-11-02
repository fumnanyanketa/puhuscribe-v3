import { useEffect, useId, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { PageFrame } from '../components/PageFrame.tsx'
import { PATHS } from '../lib/app-paths.ts'
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
  front_door: { href: PATHS.home, text: 'Back to the road' },
  account: { href: PATHS.account, text: 'Back to your account' },
  finish: { href: PATHS.home, text: 'Back to the road' },
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
  const introId = `${id}-intro`

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

  // The count shows once 100 or fewer characters are left (round 6); before that it is read with the box only.
  const left = MAX_FEEDBACK_CHARS - length
  const formId = `${id}-form`

  return (
    <PageFrame
      back={back.href}
      backLabel={back.text}
      title="Send feedback"
      contentTop="near"
      actions={
        view === 'form' ? (
          <>
            <StatusLine tone={status.tone}>{status.text}</StatusLine>
            <Button type="submit" form={formId} block busy={sending} busyLabel="Sending your message.">
              Send
            </Button>
          </>
        ) : undefined
      }
    >
      {view === 'none' && (
        <div className={styles.intro}>
          <p className={styles.text}>{FEEDBACK_NO_ACCOUNT}</p>
        </div>
      )}

      {view === 'form' && (
        <form
          id={formId}
          className={styles.form}
          noValidate
          onSubmit={(event) => {
            event.preventDefault()
            void send()
          }}
        >
          <div className={own.field}>
            <label htmlFor={id} className={own.label}>
              What should we know?
            </label>
            <textarea
              ref={field}
              id={id}
              className={own.textarea}
              rows={6}
              maxLength={MAX_FEEDBACK_CHARS}
              placeholder="What worked, what didn't, what broke."
              aria-describedby={`${introId} ${countId}`}
              value={message}
              onChange={(event) => {
                setMessage(event.target.value)
              }}
            />
            {/* The protected line, word for word, small and quiet under the box (round 6). */}
            <p id={introId} className={styles.quietText}>
              {FEEDBACK_INTRO}
            </p>
            <p id={countId} className={left <= 100 ? own.count : own.countHidden}>
              {length.toLocaleString('en-GB')} of 1,000 characters
            </p>
          </div>
        </form>
      )}

      {view === 'sent' && <StatusLine tone="neutral">{FEEDBACK_SENT}</StatusLine>}
      {view === 'loading' && <StatusLine tone="neutral">{LOADING}</StatusLine>}
      {view === 'problem' && <StatusLine tone="problem">{NOT_LOADED}</StatusLine>}

      {view === 'none' && (
        <a className={styles.smallLink} href={PATHS.home}>
          Back to the road
        </a>
      )}
    </PageFrame>
  )
}
