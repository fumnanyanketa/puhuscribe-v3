import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { callApi, isRecord } from '../lib/api.ts'
import { timeText } from '../lib/owner-numbers.ts'
import styles from './Account.module.css'
import own from './Owner.module.css'

// The owner page's "Reviewer sign-ups" section (fast route reviewers,
// factory/jobs/reviewers/spec.md, "Done when" 5): every sign up from
// /reviewers, newest first, with the name, email, thank-you name and date,
// and a Delete for each that asks first. It reads GET /api/owner/reviewers and
// deletes through POST /api/owner/reviewers/delete, which answer only the
// owner (worker/owner.ts). Everything is shown as plain text, never as HTML.

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
}: {
  rows: ReviewerSignupRow[]
  onDelete: (id: string) => Promise<string | null>
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

export function OwnerReviewers() {
  const [view, setView] = useState<View>({ kind: 'loading' })
  const firstLook = useRef<Promise<View> | null>(null)

  useEffect(() => {
    let active = true
    firstLook.current ??= callApi('/api/owner/reviewers', 'GET').then((answer): View => {
      const rows = answer?.status === 200 ? signupsOf(answer.body) : null
      return rows ? { kind: 'list', rows } : { kind: 'problem' }
    })
    void firstLook.current.then((next) => {
      if (active) setView(next)
    })
    return () => {
      active = false
    }
  }, [])

  /** Deletes one sign up; the line to show when it did not work, or null. */
  async function remove(id: string): Promise<string | null> {
    const answer = await callApi('/api/owner/reviewers/delete', 'POST', { id })
    if (answer?.status === 200 || answer?.status === 404) {
      setView((now) =>
        now.kind === 'list' ? { kind: 'list', rows: now.rows.filter((r) => r.id !== id) } : now,
      )
      return answer.status === 404 ? ALREADY_GONE : null
    }
    return NOT_DELETED
  }

  return (
    <section className={styles.section} aria-labelledby="owner-reviewers">
      <h2 id="owner-reviewers" className={styles.heading}>
        {REVIEWERS_HEADING}
      </h2>
      <p className={styles.text}>{REVIEWERS_ABOUT}</p>
      {view.kind === 'loading' && <StatusLine tone="neutral">{LOADING}</StatusLine>}
      {view.kind === 'problem' && <StatusLine tone="problem">{NOT_LOADED}</StatusLine>}
      {view.kind === 'list' && <SignupList rows={view.rows} onDelete={remove} />}
    </section>
  )
}
