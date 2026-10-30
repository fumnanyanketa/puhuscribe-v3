import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { Wordmark } from '../components/Wordmark.tsx'
import { callApi } from '../lib/api.ts'
import {
  ACCOUNT_NAMES,
  SCREEN_NAMES,
  costText,
  countryName,
  dayText,
  isOwnerNumbers,
  medianText,
  retentionText,
  speakBackText,
  timeText,
  type OwnerNumbers,
} from '../lib/owner-numbers.ts'
import styles from './Account.module.css'
import own from './Owner.module.css'

// The owner page, at /owner on the owner's own hostname
// (factory/jobs/14-analytics/spec.md, "Done when" 17, 20 and 27). One plain
// page: the launch numbers the PRD sets, the visits, the newest feedback and
// the recent crashes, with one sentence under each number saying what it
// counts. No charts, filters, date pickers, exports or per learner views.
// Everything a learner typed is shown as plain text, never as HTML.

export const NOT_OWNER = 'This account cannot open the owner page.'
const LOADING = 'Loading the numbers.'
const SIGN_IN = 'Sign in with your PuhuScribe account to see the numbers.'
const WRONG_ADDRESS = 'The owner page opens only at its own address.'
const NOT_LOADED = 'The numbers could not be loaded. Check your internet connection, then try again.'
export const TEST_ERROR_SENT = 'A test error was thrown. Reload the page to see it under Crashes.'

type View =
  | { kind: 'loading' | 'signed_out' | 'not_owner' | 'wrong_address' | 'problem' }
  | { kind: 'numbers'; numbers: OwnerNumbers }

/** The error the "Send a test error" button throws, so the owner can see the crash list work. */
class OwnerPageTestError extends Error {
  constructor() {
    super('A test error from the owner page.')
    this.name = 'OwnerPageTestError'
  }
}

function Figure({
  title,
  value,
  goal,
  about,
}: {
  title: string
  value: string
  goal?: string
  about: string
}) {
  return (
    <div className={own.number}>
      <h3 className={own.numberTitle}>{title}</h3>
      <p className={own.value}>{value}</p>
      {goal && <p className={own.goal}>{goal}</p>}
      <p className={styles.quietText}>{about}</p>
    </div>
  )
}

function Numbers({ numbers }: { numbers: OwnerNumbers }) {
  const [testSent, setTestSent] = useState(false)
  const { day7_retention: retention, median_session_minutes: median } = numbers
  return (
    <div className={styles.notice}>
      <section className={styles.section} aria-labelledby="owner-learners">
        <h2 id="owner-learners" className={styles.heading}>
          Learners
        </h2>
        <div className={own.numbers}>
          <Figure
            title="Active learners"
            value={String(numbers.active_learners)}
            about="Learners who started a session in the last 30 days. This is the tester count."
          />
          <Figure
            title="Day 7 retention"
            value={retentionText(retention)}
            goal="Goal: at least 25 percent."
            about="Learners whose first session was on a day whose day 7 has passed in the last 30 days, and how many of them started a session exactly 7 days later."
          />
          <Figure
            title="Median session"
            value={medianText(median)}
            goal="Goal: at least 8 minutes."
            about={`The middle length of the sessions started in the last 30 days that ended within 2 hours. ${String(median.left_out)} left out (not finished, or longer).`}
          />
          <Figure
            title="Speak back"
            value={speakBackText(numbers.speak_back)}
            goal="Goal: at least half."
            about="Active learners who asked for speaking feedback at least once in the last 30 days."
          />
          <Figure
            title="AI and speech cost"
            value={costText(numbers.ai_cost_usd)}
            goal="PRD target: under €0.75 a month."
            about="Every AI and speech cost recorded for learners in the last 30 days, in US dollars as recorded."
          />
        </div>
      </section>

      <section className={styles.section} aria-labelledby="owner-visits">
        <h2 id="owner-visits" className={styles.heading}>
          Visits
        </h2>
        <p className={styles.text}>
          One visit is one arrival at the app from a link, a bookmark, the home screen or the typed address.
          Moving between screens does not count, and nobody is counted only once.
        </p>
        <div className={own.tableBox}>
          <table className={own.table}>
            <caption className={own.caption}>Visits by day, last 30 days</caption>
            <thead>
              <tr>
                <th scope="col">Day</th>
                <th scope="col">All visits</th>
                <th scope="col">From Finland</th>
              </tr>
            </thead>
            <tbody>
              {numbers.visits_by_day.map((row) => (
                <tr key={row.day}>
                  <th scope="row">{dayText(row.day)}</th>
                  <td>{row.visits}</td>
                  <td>{row.fi}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {numbers.visits_by_country.length === 0 ? (
          <p className={styles.text}>No visits in the last 30 days.</p>
        ) : (
          <div className={own.tableBox}>
            <table className={own.table}>
              <caption className={own.caption}>Visits by country, last 30 days</caption>
              <thead>
                <tr>
                  <th scope="col">Country</th>
                  <th scope="col">Visits</th>
                </tr>
              </thead>
              <tbody>
                {numbers.visits_by_country.map((row) => (
                  <tr key={row.country}>
                    <th scope="row">{countryName(row.country)}</th>
                    <td>{row.visits}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <section className={styles.section} aria-labelledby="owner-feedback">
        <h2 id="owner-feedback" className={styles.heading}>
          Feedback
        </h2>
        <p className={styles.text}>The newest 50 messages from learners, shown exactly as typed.</p>
        {numbers.feedback.length === 0 ? (
          <p className={styles.text}>No feedback yet.</p>
        ) : (
          <ul className={styles.cards} data-owner="feedback">
            {numbers.feedback.map((item, index) => (
              <li key={`${item.created_at}-${String(index)}`} className={styles.item}>
                <p className={own.message}>{item.message}</p>
                <p className={styles.quietText}>
                  {timeText(item.created_at)}. {SCREEN_NAMES[item.screen] ?? item.screen}.{' '}
                  {ACCOUNT_NAMES[item.account] ?? item.account}.
                </p>
              </li>
            ))}
          </ul>
        )}
      </section>

      <section className={styles.section} aria-labelledby="owner-crashes">
        <h2 id="owner-crashes" className={styles.heading}>
          Crashes
        </h2>
        <p className={styles.text}>
          Errors from the last 30 days, grouped by error and place, newest first. They hold nothing that
          identifies a learner.
        </p>
        <div className={styles.actions}>
          <Button
            variant="secondary"
            block
            onClick={() => {
              setTestSent(true)
              // A real error, thrown outside React, so it reaches the error
              // listener and is reported like any other.
              window.setTimeout(() => {
                throw new OwnerPageTestError()
              }, 0)
            }}
          >
            Send a test error
          </Button>
          <StatusLine tone="neutral">{testSent ? TEST_ERROR_SENT : ''}</StatusLine>
        </div>
        {numbers.crashes.length === 0 ? (
          <p className={styles.text}>No crashes in the last 30 days.</p>
        ) : (
          <ul className={styles.cards} data-owner="crashes">
            {numbers.crashes.map((crash) => (
              <li key={`${crash.name}-${crash.last_seen}`} className={styles.item}>
                <h3 className={own.crashName}>{crash.name}</h3>
                <p className={own.message}>{crash.message}</p>
                <p className={styles.quietText}>
                  Seen {crash.count === 1 ? 'once' : `${String(crash.count)} times`} in the last 30 days, last
                  on {timeText(crash.last_seen)}.
                </p>
                <p className={styles.quietText}>
                  Path {crash.path}. {crash.browser}. App version {crash.app_version}.{' '}
                  {crash.source === 'worker' ? 'In the Worker.' : 'In the browser.'}
                </p>
                {crash.frames.length > 0 && (
                  <ol className={own.frames}>
                    {crash.frames.map((frame, index) => (
                      <li key={index}>
                        {frame.file}:{frame.line}:{frame.column}
                        {frame.fn ? ` ${frame.fn}` : ''}
                      </li>
                    ))}
                  </ol>
                )}
              </li>
            ))}
          </ul>
        )}
      </section>

      <p className={styles.quietText}>These numbers were worked out on {timeText(numbers.computed_at)}.</p>
    </div>
  )
}

export function OwnerPage() {
  const [view, setView] = useState<View>({ kind: 'loading' })
  const firstLook = useRef<Promise<View> | null>(null)

  useEffect(() => {
    let active = true
    firstLook.current ??= callApi('/api/owner/dashboard', 'GET').then((answer): View => {
      if (answer?.status === 200 && isOwnerNumbers(answer.body))
        return { kind: 'numbers', numbers: answer.body }
      if (answer?.status === 401) return { kind: 'signed_out' }
      if (answer?.status === 403) return { kind: 'not_owner' }
      if (answer?.status === 404) return { kind: 'wrong_address' }
      return { kind: 'problem' }
    })
    void firstLook.current.then((next) => {
      if (active) setView(next)
    })
    return () => {
      active = false
    }
  }, [])

  return (
    <main className={`${styles.page} ${own.page}`}>
      <div className={styles.top}>
        <Wordmark height={36} />
      </div>
      <div className={styles.intro}>
        <h1 className={styles.title}>Owner page</h1>
        <p className={styles.text}>
          The launch numbers for the last 30 days. Only the owner can open this page.
        </p>
      </div>
      {view.kind === 'loading' && <StatusLine tone="neutral">{LOADING}</StatusLine>}
      {view.kind === 'signed_out' && (
        <div className={styles.actions}>
          <p className={styles.text}>{SIGN_IN}</p>
          <Button
            block
            onClick={() => {
              window.location.assign('/sign-in')
            }}
          >
            Sign in with your email
          </Button>
        </div>
      )}
      {view.kind === 'not_owner' && <StatusLine tone="problem">{NOT_OWNER}</StatusLine>}
      {view.kind === 'wrong_address' && <StatusLine tone="problem">{WRONG_ADDRESS}</StatusLine>}
      {view.kind === 'problem' && <StatusLine tone="problem">{NOT_LOADED}</StatusLine>}
      {view.kind === 'numbers' && <Numbers numbers={view.numbers} />}
    </main>
  )
}
