import { useId, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { isRecord, type ApiAnswer } from '../lib/api.ts'
import { timeText } from '../lib/owner-numbers.ts'
import { ANSWER_LABELS, REVIEW_ANSWERS, REVIEW_BATCHES, type ReviewAnswer } from '../lib/review-link.ts'
import styles from './Account.module.css'
import own from './Owner.module.css'

// The owner page's side of the private review links (fast route review-links,
// factory/jobs/review-links/spec.md, "Done when" 1 and 6). Under each
// reviewer sign up: every link sent (its batch, when, and how many lines are
// answered) and "Send review link" with a batch choice of 1 to 4. One press
// sends one email (POST /api/owner/review-links/send) and the list shows the
// new link. And the "Review answers" section: every "Needs a fix" and "Not
// sure" answer, newest first, with the dialogue, the line, the note and the
// reviewer's name. Everything is shown as plain text, never as HTML.

export interface ReviewLinkRow {
  id: string
  signup_id: string
  batch: number
  sent_at: string
  lines: number
  answered: number
}

export interface ReviewAnswerRow {
  link_id: string
  line_id: number
  answer: ReviewAnswer
  note: string | null
  answered_at: string
  name: string
  dialogue: string
  position: number
  speaker: string
  spoken: string
  written: string
  english: string
}

export interface ReviewLinksView {
  links: ReviewLinkRow[]
  answers: ReviewAnswerRow[]
  /** False when the Worker has no BREVO_API_KEY, so no email can be sent. */
  emailReady: boolean
}

export const SEND_LINK = 'Send review link'
export const BATCH_LABEL = 'Batch'
export const EMAIL_NOT_SET =
  'Email sending is not set up on this Worker (BREVO_API_KEY is missing), so no review link can be sent.'
export const NOT_SENT =
  'The review link was not sent, and nothing was saved. Check your internet connection, then try again.'
export const EMAIL_REFUSED =
  'Brevo did not take the email, so the review link was not sent and nothing was saved.'
export const NO_LINKS = 'No review link sent yet.'
export const ANSWERS_HEADING = 'Review answers'
export const ANSWERS_ABOUT =
  'Every "Needs a fix" and "Not sure" answer from the review links, newest first. They are deleted with the sign-up.'
export const NO_ANSWERS = 'No answers to look at yet.'

const isText = (value: unknown): value is string => typeof value === 'string'
const isNumber = (value: unknown): value is number => typeof value === 'number' && Number.isFinite(value)

function isLink(value: unknown): value is ReviewLinkRow {
  return (
    isRecord(value) &&
    isText(value.id) &&
    isText(value.signup_id) &&
    isNumber(value.batch) &&
    isText(value.sent_at) &&
    isNumber(value.lines) &&
    isNumber(value.answered)
  )
}

function isAnswerRow(value: unknown): value is ReviewAnswerRow {
  return (
    isRecord(value) &&
    isText(value.link_id) &&
    isNumber(value.line_id) &&
    isText(value.answer) &&
    (REVIEW_ANSWERS as readonly string[]).includes(value.answer) &&
    (value.note === null || isText(value.note)) &&
    isText(value.answered_at) &&
    isText(value.name) &&
    isText(value.dialogue) &&
    isNumber(value.position) &&
    isText(value.speaker) &&
    isText(value.spoken) &&
    isText(value.written) &&
    isText(value.english)
  )
}

/** The links and answers from GET /api/owner/review-links, or null when the answer is not one. */
export function reviewLinksOf(body: unknown): ReviewLinksView | null {
  if (!isRecord(body) || !Array.isArray(body.links) || !Array.isArray(body.answers)) return null
  const links: unknown[] = body.links
  const answers: unknown[] = body.answers
  if (!links.every(isLink) || !answers.every(isAnswerRow)) return null
  return {
    links,
    answers,
    emailReady: body.emailReady === true,
  }
}

/** The line for a send that did not work. */
export function sendProblemOf(answer: ApiAnswer | null): string {
  if (answer === null) return NOT_SENT
  const error = isRecord(answer.body) ? answer.body.error : null
  if (error === 'email_not_set') return EMAIL_NOT_SET
  if (error === 'not_sent') return EMAIL_REFUSED
  if (answer.status === 404) return 'That sign-up is no longer there.'
  return NOT_SENT
}

/** One line about a link that was sent: its batch, when, and the progress. */
export function linkText(link: ReviewLinkRow): string {
  return `Batch ${String(link.batch)} sent on ${timeText(link.sent_at)}. ${String(link.answered)} of ${String(link.lines)} lines answered.`
}

/** The batch to offer first: the lowest not yet sent to this person, or 1 when all were. */
export function nextBatch(links: readonly ReviewLinkRow[]): number {
  const sent = new Set(links.map((l) => l.batch))
  return REVIEW_BATCHES.find((b) => !sent.has(b)) ?? 1
}

export type SendLink = (signupId: string, batch: number) => Promise<{ text: string; tone: StatusTone }>

/** Under one sign up: the links sent so far and "Send review link" with its batch choice. */
export function SignupLinks({
  signupId,
  name,
  links,
  onSend,
}: {
  signupId: string
  name: string
  links: ReviewLinkRow[]
  onSend: SendLink
}) {
  const [batch, setBatch] = useState(() => nextBatch(links))
  const [sending, setSending] = useState(false)
  const [status, setStatus] = useState<{ text: string; tone: StatusTone }>({ text: '', tone: 'neutral' })
  const busy = useRef(false)
  const id = useId()
  return (
    <div className={own.links} data-owner="review-links">
      {links.length === 0 ? (
        <p className={styles.quietText}>{NO_LINKS}</p>
      ) : (
        links.map((link) => (
          <p key={link.id} className={styles.quietText}>
            {linkText(link)}
          </p>
        ))
      )}
      <div className={own.send}>
        <label htmlFor={`${id}-batch`} className={own.batchLabel}>
          {BATCH_LABEL}
        </label>
        <select
          id={`${id}-batch`}
          className={own.batch}
          value={batch}
          disabled={sending}
          onChange={(event) => {
            setBatch(Number(event.target.value))
          }}
        >
          {REVIEW_BATCHES.map((b) => (
            <option key={b} value={b}>
              {b}
            </option>
          ))}
        </select>
        <Button
          variant="secondary"
          arrow={false}
          busy={sending}
          busyLabel="Sending the review link."
          aria-label={`${SEND_LINK} to ${name}`}
          onClick={() => {
            // One press sends one email: a second tap while sending is ignored.
            if (busy.current) return
            busy.current = true
            setSending(true)
            setStatus({ text: '', tone: 'neutral' })
            void onSend(signupId, batch).then((result) => {
              busy.current = false
              setSending(false)
              setStatus(result)
            })
          }}
        >
          {SEND_LINK}
        </Button>
      </div>
      <StatusLine tone={status.tone}>{status.text}</StatusLine>
    </div>
  )
}

/** The "Review answers" list: what the owner should look at, newest first. */
export function ReviewAnswersList({ answers }: { answers: ReviewAnswerRow[] }) {
  if (answers.length === 0) return <p className={styles.text}>{NO_ANSWERS}</p>
  return (
    <ul className={styles.cards} data-owner="review-answers">
      {answers.map((row) => (
        <li key={`${row.link_id}-${String(row.line_id)}`} className={styles.item}>
          <p className={own.message}>
            {ANSWER_LABELS[row.answer]}, from {row.name}
          </p>
          <p className={styles.quietText}>
            {row.dialogue}, line {row.position}, {row.speaker}. Answered on {timeText(row.answered_at)}.
          </p>
          <p className={own.message} lang="fi">
            {row.spoken}
          </p>
          <p className={own.message} lang="fi">
            {row.written}
          </p>
          <p className={styles.quietText}>{row.english}</p>
          {row.note ? <p className={own.message}>Note: {row.note}</p> : null}
        </li>
      ))}
    </ul>
  )
}
