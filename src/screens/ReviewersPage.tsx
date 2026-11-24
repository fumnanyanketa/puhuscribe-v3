import { useEffect, useId, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { PageFrame } from '../components/PageFrame.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { TextField } from '../components/TextField.tsx'
import { callApi, isRecord, type ApiAnswer } from '../lib/api.ts'
import { PATHS } from '../lib/app-paths.ts'
import { loadHumanCheck, REVIEWERS_ACTION, runHumanCheck } from '../lib/human-check.ts'
import { parseReviewerSignup, type ReviewerField } from '../lib/reviewer-signup.ts'
import { REVIEWER_CONTACT } from '../privacy/data-inventory.ts'
import { CheckSlot } from '../road/CheckSlot.tsx'
import styles from './Account.module.css'
import own from './Reviewers.module.css'

// The native speaker reviewer sign up page, at /reviewers (fast route
// reviewers, factory/jobs/reviewers/spec.md, "Done when" 1, 2, 3 and 8). A
// public page outside /learn, drawn by the app shell: it needs no account,
// sets no cookie and calls no /api route until Send. The words are the
// owner's, word for word from the spec.
//
// Send posts the three fields to POST /api/reviewers. The Worker answers
// check_needed with the public site key, the Cloudflare Turnstile check runs
// above the button (the guest Start's check, src/lib/human-check.ts), and the
// form is sent again with its token. A second tap while sending is ignored.

export const REVIEWERS_TITLE = 'Please help us review the Finnish language in Aleksi'
export const REVIEWERS_INTRO =
  "Aleksi teaches puhekieli and kirjakieli, so if Finnish is your first language, I'd love your help checking it."
export const REVIEWERS_NEXT =
  "After you sign up, I'll email you a short list of phrases from the app. You tell me anything that sounds wrong or unnatural."
export const NAME_LABEL = 'Your name'
export const EMAIL_LABEL = 'Your email'
export const THANKS_LABEL = 'Name for the thank-you in my next video (optional)'
export const THANKS_HINT = "Leave it empty if you'd rather not be named."
export const SIGN_UP = 'Sign up'
export const SMALL_PRINT = `I use these details only to contact you about reviewing and to thank you. I keep them until the review is done, and you can ask me to delete them any time at ${REVIEWER_CONTACT}.`
export const REVIEWERS_SENT = "Thank you. I'll email you the phrases soon."

// What went wrong, each line saying only what happened (AGENTS.md lesson).
export const FIELD_PROBLEMS: Record<ReviewerField, string> = {
  name: 'Please write your name, up to 100 characters.',
  email: 'Please check your email address.',
  thanks_name: 'Please keep the thank-you name to 100 characters.',
}
export const LIMIT_REACHED = 'The sign-up limit for today is reached. Please try again tomorrow.'
export const CHECK_ASKING_REVIEWERS =
  'Cloudflare needs one quick check that you are a person before your sign-up is sent.'
export const CHECK_FAILED_REVIEWERS = 'The quick safety check did not go through. Press Sign up to try again.'
export const CHECK_UNAVAILABLE_REVIEWERS =
  'The quick safety check could not load. Check your internet connection, then press Sign up again.'
export const NOT_SAVED = 'Your sign-up was not saved. Please try again in a moment.'
export const NOT_SENT = 'Your sign-up was not sent. Check your internet connection, then try again.'

/** The public Turnstile site key when the Worker asks for the bot check first. */
function siteKeyOf(answer: ApiAnswer | null): string | null {
  if (answer?.status !== 403 || !isRecord(answer.body)) return null
  const { error, siteKey } = answer.body
  return (error === 'check_needed' || error === 'check_failed') &&
    typeof siteKey === 'string' &&
    siteKey !== ''
    ? siteKey
    : null
}

/** The line for an answer that is not a 201. */
export function problemOf(answer: ApiAnswer | null): string {
  if (answer === null) return NOT_SENT
  const body = isRecord(answer.body) ? answer.body : {}
  if (answer.status === 400 && typeof body.field === 'string' && body.field in FIELD_PROBLEMS)
    return FIELD_PROBLEMS[body.field as ReviewerField]
  if (answer.status === 429) return LIMIT_REACHED
  if (body.error === 'check_failed') return CHECK_FAILED_REVIEWERS
  if (body.error === 'check_unavailable') return CHECK_UNAVAILABLE_REVIEWERS
  return NOT_SAVED
}

export function ReviewersPage() {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [thanksName, setThanksName] = useState('')
  const [sending, setSending] = useState(false)
  const [sent, setSent] = useState(false)
  const [asking, setAsking] = useState(false)
  const [status, setStatus] = useState<{ text: string; tone: StatusTone }>({ text: '', tone: 'neutral' })
  const busy = useRef(false)
  const checkSlot = useRef<HTMLDivElement>(null)
  const nameField = useRef<HTMLInputElement>(null)
  const emailField = useRef<HTMLInputElement>(null)
  const thanksField = useRef<HTMLInputElement>(null)
  /** Moves focus to the field a problem line is about. */
  function focusField(field: ReviewerField) {
    const target = field === 'name' ? nameField : field === 'email' ? emailField : thanksField
    target.current?.focus()
  }
  const id = useId()
  const formId = `${id}-form`

  useEffect(() => {
    const before = document.title
    document.title = `${REVIEWERS_TITLE} | Aleksi`
    return () => {
      document.title = before
    }
  }, [])

  async function send() {
    // A second tap or Enter while sending would sign up twice. The ref also
    // stops a second tap that lands before React draws the busy button.
    if (busy.current) return
    const checked = parseReviewerSignup({ name, email, thanksName })
    if ('bad' in checked) {
      setStatus({ text: FIELD_PROBLEMS[checked.bad], tone: 'gentle' })
      focusField(checked.bad)
      return
    }
    busy.current = true
    setSending(true)
    setStatus({ text: '', tone: 'neutral' })
    // The check will most likely be needed, so its script starts loading now, beside the first request.
    void loadHumanCheck()
    const form = { name, email, thanksName }
    let answer = await callApi('/api/reviewers', 'POST', form)
    const siteKey = siteKeyOf(answer)
    if (siteKey) {
      const slot = checkSlot.current
      const result = slot
        ? await runHumanCheck(slot, siteKey, setAsking, REVIEWERS_ACTION)
        : ({ problem: 'unavailable' } as const)
      if ('problem' in result) {
        busy.current = false
        setSending(false)
        setStatus({
          text: result.problem === 'failed' ? CHECK_FAILED_REVIEWERS : CHECK_UNAVAILABLE_REVIEWERS,
          tone: 'problem',
        })
        return
      }
      answer = await callApi('/api/reviewers', 'POST', { ...form, turnstileToken: result.token })
    }
    busy.current = false
    setSending(false)
    if (answer?.status === 201) {
      setSent(true)
      return
    }
    const field = answer?.status === 400 && isRecord(answer.body) ? answer.body.field : null
    setStatus({
      text: problemOf(answer),
      tone: answer?.status === 400 || answer?.status === 429 ? 'gentle' : 'problem',
    })
    if (field === 'name' || field === 'email' || field === 'thanks_name') focusField(field)
  }

  return (
    <PageFrame
      back={PATHS.landing}
      backLabel="Back to Aleksi"
      contentTop="near"
      actions={
        sent ? undefined : (
          <>
            <CheckSlot checkRef={checkSlot} asking={asking} note={CHECK_ASKING_REVIEWERS} />
            <StatusLine tone={status.tone}>{status.text}</StatusLine>
            <Button type="submit" form={formId} block busy={sending} busyLabel="Sending your sign-up.">
              {SIGN_UP}
            </Button>
          </>
        )
      }
    >
      <h1 className={own.title}>{REVIEWERS_TITLE}</h1>
      <div className={own.intro}>
        <p className={styles.summary}>{REVIEWERS_INTRO}</p>
        <p className={styles.summary}>{REVIEWERS_NEXT}</p>
      </div>

      {sent ? (
        <StatusLine tone="neutral">{REVIEWERS_SENT}</StatusLine>
      ) : (
        <form
          id={formId}
          className={own.form}
          noValidate
          onSubmit={(event) => {
            event.preventDefault()
            void send()
          }}
        >
          <TextField
            ref={nameField}
            id={`${id}-name`}
            label={NAME_LABEL}
            showLabel
            autoComplete="name"
            value={name}
            onChange={(event) => {
              setName(event.target.value)
            }}
          />
          <TextField
            ref={emailField}
            id={`${id}-email`}
            label={EMAIL_LABEL}
            showLabel
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
          <TextField
            ref={thanksField}
            id={`${id}-thanks`}
            label={THANKS_LABEL}
            showLabel
            hint={THANKS_HINT}
            autoComplete="off"
            value={thanksName}
            onChange={(event) => {
              setThanksName(event.target.value)
            }}
          />
          <div className={own.smallPrint}>
            <p className={styles.quietText}>{SMALL_PRINT}</p>
            {/* On its own line, so its 44 px tap area does not stretch a line of the small print. */}
            <p className={styles.quietText}>
              <a className={styles.inlineLink} href={PATHS.privacy}>
                Read the privacy notice
              </a>
            </p>
          </div>
        </form>
      )}
    </PageFrame>
  )
}
