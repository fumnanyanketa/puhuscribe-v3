import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { callApi, isRecord, type ApiAnswer } from '../lib/api.ts'
import { timeText } from '../lib/owner-numbers.ts'
import styles from './Account.module.css'
import own from './Owner.module.css'
import {
  ANSWERS_ABOUT,
  ANSWERS_HEADING,
  EMAIL_NOT_SET,
  ReviewAnswersList,
  reviewLinksOf,
  sendProblemOf,
  SignupLinks,
  type ReviewLinksView,
  type SendLink,
} from './OwnerReviewLinks.tsx'

// The owner page's "Reviewer sign-ups" section (fast route reviewers,
// factory/jobs/reviewers/spec.md, "Done when" 5): every sign up from
// /reviewers, newest first, with the name, email, thank-you name and date,
// and a Delete for each that asks first. It reads GET /api/owner/reviewers and
// deletes through POST /api/owner/reviewers/delete, which answer only the
// owner (worker/owner.ts). Everything is shown as plain text, never as HTML.
//
// Fast route review-links adds, under each sign up, the review links sent and
// "Send review link" (src/screens/OwnerReviewLinks.tsx), and a second section,
// "Review answers", both read from GET /api/owner/review-links.

export interface ReviewerSignupRow {
  id: string
  name: string
  email: string
  thanks_name: string | null
  created_at: string
}

export const REVIEWERS_HEADING = 'Reviewer sign-ups'
export const REVIEWERS_ABOUT =
  'People who offered to check the Finnish at meetaleksi.com/reviewers, newest first. They are kept until you delete them.'
export const NO_SIGNUPS = 'No sign-ups yet.'
const LOADING = 'Loading the sign-ups.'
const NOT_LOADED = 'The sign-ups could not be loaded. Check your internet connection, then reload the page.'
export const NOT_DELETED = 'The sign-up was not deleted. Check your internet connection, then try again.'
export const ALREADY_GONE = 'That sign-up is no longer there.'

function isRow(value: unknown): value is ReviewerSignupRow {
  return (
    isRecord(value) &&
    typeof value.id === 'string' &&
    typeof value.name === 'string' &&
    typeof value.email === 'string' &&
    (value.thanks_name === null || typeof value.thanks_name === 'string') &&
    typeof value.created_at === 'string'
  )
}

/** The list from GET /api/owner/reviewers, or null when the answer is not one. */
export function signupsOf(body: unknown): ReviewerSignupRow[] | null {
  if (!isRecord(body) || !Array.isArray(body.signups)) return null
  return body.signups.every(isRow) ? body.signups : null
}

type View = { kind: 'loading' | 'problem' } | { kind: 'list'; rows: ReviewerSignupRow[] }

export function SignupList({
  rows,
  onDelete,
  links,
  onSend,
}: {
  rows: ReviewerSignupRow[]
  onDelete: (id: string) => Promise<string | null>
  /** The review links sent so far (fast route review-links); without them no send control is drawn. */
  links?: ReviewLinksView['links']
  onSend?: SendLink
}) {
  const [asking, setAsking] = useState<string | null>(null)
  const [deleting, setDeleting] = useState(false)
  const [problem, setProblem] = useState('')
  if (rows.length === 0) return <p className={styles.text}>{NO_SIGNUPS}</p>
  return (
    <>
      <StatusLine tone="problem">{problem}</StatusLine>
      <ul className={styles.cards} data-owner="reviewers">
        {rows.map((row) => (
          <li key={row.id} className={styles.item}>
            <p className={own.message}>{row.name}</p>
            <p className={own.message}>{row.email}</p>
            <p className={styles.quietText}>
              {row.thanks_name ? `Thank-you name: ${row.thanks_name}.` : 'No thank-you name.'} Signed up on{' '}
              {timeText(row.created_at)}.
            </p>
            {links && onSend ? (
              <SignupLinks
                signupId={row.id}
                name={row.name}
                links={links.filter((link) => link.signup_id === row.id)}
                onSend={onSend}
              />
            ) : null}
            {asking === row.id ? (
              <div className={own.confirm}>
                <p className={styles.text}>Delete the sign-up from {row.name}? This cannot be undone.</p>
                <Button
                  variant="danger"
                  block
                  busy={deleting}
                  busyLabel="Deleting the sign-up."
                  onClick={() => {
                    if (deleting) return
                    setDeleting(true)
                    setProblem('')
                    void onDelete(row.id).then((result) => {
                      setDeleting(false)
                      setAsking(null)
                      setProblem(result ?? '')
                    })
                  }}
                >
                  Delete for good
                </Button>
                <Button
                  variant="quiet"
                  disabled={deleting}
                  onClick={() => {
                    setAsking(null)
                  }}
                >
                  Keep it
                </Button>
              </div>
            ) : (
              <Button
                variant="quiet"
                aria-label={`Delete the sign-up from ${row.name}`}
                onClick={() => {
                  setProblem('')
                  setAsking(row.id)
                }}
              >
                Delete
              </Button>
            )}
          </li>
        ))}
      </ul>
    </>
  )
}

type LinksLoad = { kind: 'loading' | 'problem' } | { kind: 'ready'; data: ReviewLinksView }

const LINKS_NOT_LOADED =
  'The review links and answers could not be loaded. Check your internet connection, then reload the page.'

function readLinks(answer: ApiAnswer | null): LinksLoad {
  const data = answer?.status === 200 ? reviewLinksOf(answer.body) : null
  return data ? { kind: 'ready', data } : { kind: 'problem' }
}

export function OwnerReviewers() {
  const [view, setView] = useState<View>({ kind: 'loading' })
  const [linksLoad, setLinksLoad] = useState<LinksLoad>({ kind: 'loading' })
  const firstLook = useRef<Promise<[View, LinksLoad]> | null>(null)

  useEffect(() => {
    let active = true
    firstLook.current ??= Promise.all([
      callApi('/api/owner/reviewers', 'GET').then((answer): View => {
        const rows = answer?.status === 200 ? signupsOf(answer.body) : null
        return rows ? { kind: 'list', rows } : { kind: 'problem' }
      }),
      callApi('/api/owner/review-links', 'GET').then(readLinks),
    ])
    void firstLook.current.then(([next, nextLinks]) => {
      if (!active) return
      setView(next)
      setLinksLoad(nextLinks)
    })
    return () => {
      active = false
    }
  }, [])

  /** Sends one review link; the line to show under the sign up. The list then shows the new link. */
  const send: SendLink = async (signupId, batch) => {
    const answer = await callApi('/api/owner/review-links/send', 'POST', { signupId, batch })
    if (answer?.status !== 201) return { text: sendProblemOf(answer), tone: 'problem' }
    const fresh = readLinks(await callApi('/api/owner/review-links', 'GET'))
    if (fresh.kind === 'ready') setLinksLoad(fresh)
    return { text: `Batch ${String(batch)} sent.`, tone: 'neutral' }
  }

  /** Deletes one sign up; the line to show when it did not work, or null. */
  async function remove(id: string): Promise<string | null> {
    const answer = await callApi('/api/owner/reviewers/delete', 'POST', { id })
    if (answer?.status === 200 || answer?.status === 404) {
      setView((now) =>
        now.kind === 'list' ? { kind: 'list', rows: now.rows.filter((r) => r.id !== id) } : now,
      )
      // The sign up's links and answers went with it (fast route review-links).
      const fresh = readLinks(await callApi('/api/owner/review-links', 'GET'))
      if (fresh.kind === 'ready') setLinksLoad(fresh)
      return answer.status === 404 ? ALREADY_GONE : null
    }
    return NOT_DELETED
  }

  return (
    <>
      <section className={styles.section} aria-labelledby="owner-reviewers">
        <h2 id="owner-reviewers" className={styles.heading}>
          {REVIEWERS_HEADING}
        </h2>
        <p className={styles.text}>{REVIEWERS_ABOUT}</p>
        {view.kind === 'loading' && <StatusLine tone="neutral">{LOADING}</StatusLine>}
        {view.kind === 'problem' && <StatusLine tone="problem">{NOT_LOADED}</StatusLine>}
        {linksLoad.kind === 'ready' && !linksLoad.data.emailReady && (
          <StatusLine tone="problem">{EMAIL_NOT_SET}</StatusLine>
        )}
        {linksLoad.kind === 'problem' && <StatusLine tone="problem">{LINKS_NOT_LOADED}</StatusLine>}
        {view.kind === 'list' && (
          <SignupList
            rows={view.rows}
            onDelete={remove}
            {...(linksLoad.kind === 'ready' ? { links: linksLoad.data.links, onSend: send } : {})}
          />
        )}
      </section>
      <OwnerReviewAnswers answers={linksLoad.kind === 'ready' ? linksLoad.data.answers : null} />
    </>
  )
}

/** The owner page's "Review answers" section (fast route review-links, "Done when" 6). */
export function OwnerReviewAnswers({ answers }: { answers: ReviewLinksView['answers'] | null }) {
  return (
    <section className={styles.section} aria-labelledby="owner-review-answers">
      <h2 id="owner-review-answers" className={styles.heading}>
        {ANSWERS_HEADING}
      </h2>
      <p className={styles.text}>{ANSWERS_ABOUT}</p>
      {answers === null ? (
        <StatusLine tone="neutral">Loading the answers.</StatusLine>
      ) : (
        <ReviewAnswersList answers={answers} />
      )}
    </section>
  )
}
