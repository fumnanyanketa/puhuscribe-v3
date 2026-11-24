import { useEffect, useId, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { PageFrame } from '../components/PageFrame.tsx'
import { StatusLine, type StatusTone } from '../components/StatusLine.tsx'
import { callApi, isRecord, type ApiAnswer } from '../lib/api.ts'
import { PATHS } from '../lib/app-paths.ts'
import {
  ANSWER_LABELS,
  MAX_REVIEW_NOTE,
  REVIEW_ANSWERS,
  cleanNote,
  progressOf,
  reviewPagePath,
  reviewPlaceOf,
  type ReviewAnswer,
} from '../lib/review-link.ts'
import { characterCount } from '../lib/reviewer-signup.ts'
import type { SessionLine, SessionWord } from '../lib/session-types.ts'
import styles from './Account.module.css'
import feedback from './Feedback.module.css'
import { LineCard } from './LineCard.tsx'
import own from './ReviewLink.module.css'

// The private review pages (fast route review-links,
// factory/jobs/review-links/spec.md, "Done when" 2, 3, 4 and 7). The link
// /review/<secret> opens the list of the batch's dialogues; each dialogue is
// /review/<secret>/<dialogue id>. No account and no sign in: the secret in the
// address is the only key, and the Worker checks it through the database on
// every request. A wrong, deleted or malformed secret shows one plain page,
// "This link does not work".
//
// Each line is drawn by the session's own line card (LineCard: the speaker,
// the spoken and written Finnish with a play button each, playing the same
// audio files as the app, and the English meaning), with three answers under
// it. An answer saves on tap (POST /api/review/<secret>/answers) and the line
// says "Saved."; "Needs a fix" opens a box for what should change, up to 500
// characters, saved with its own button. A failed save says so and keeps what
// was typed. A tap while a line is saving is ignored.

export const BROKEN_TITLE = 'This link does not work'
export const LIST_TITLE = 'Check the Finnish in Aleksi'
export const LIST_INTRO =
  'Thank you for helping. Open a dialogue, listen to each line, read it in spoken and written Finnish, and mark it. Your answers save as you go, so you can stop and come back with this link.'
export const NOTE_LABEL = 'What should change?'
export const SAVE_NOTE = 'Save the note'
export const SAVED = 'Saved.'
export const NOT_SAVED_OFFLINE = 'Not saved. Check your internet connection, then try again.'
export const NOT_SAVED_LIMIT =
  'Not saved, because many answers came in at once. Wait a minute, then try again.'
export const NOT_SAVED_GONE = 'Not saved, because this link no longer works.'
export const NOT_SAVED = 'Not saved. Please try again in a moment.'
export const NOTE_TOO_LONG = `Please keep the note to ${String(MAX_REVIEW_NOTE)} characters.`
export const NOT_LOADED =
  'The review could not be loaded. Check your internet connection, then reload the page.'
const LOADING = 'Loading the review.'

export interface ReviewDialogueItem {
  id: number
  position: number
  title: string
  stop: string
  lines: number
  answered: number
}

export interface ReviewOverview {
  batch: number
  dialogues: ReviewDialogueItem[]
}

export interface ReviewLine {
  id: number
  position: number
  speaker: string
  spoken: string
  written: string
  english: string
  spokenAudio: string | null
  writtenAudio: string | null
  answer: ReviewAnswer | null
  note: string | null
}

export interface ReviewDialogue {
  id: number
  position: number
  of: number
  title: string
  stop: string
  previous: number | null
  next: number | null
  lines: ReviewLine[]
}

const isNumber = (value: unknown): value is number => typeof value === 'number' && Number.isFinite(value)
const isText = (value: unknown): value is string => typeof value === 'string'
const isAnswer = (value: unknown): value is ReviewAnswer =>
  typeof value === 'string' && (REVIEW_ANSWERS as readonly string[]).includes(value)

/** The list from GET /api/review/<secret>, or null when the answer is not one. */
export function overviewOf(body: unknown): ReviewOverview | null {
  if (!isRecord(body) || !isNumber(body.batch) || !Array.isArray(body.dialogues)) return null
  const items: unknown[] = body.dialogues
  const ok = items.every(
    (d) =>
      isRecord(d) &&
      isNumber(d.id) &&
      isNumber(d.position) &&
      isText(d.title) &&
      isText(d.stop) &&
      isNumber(d.lines) &&
      isNumber(d.answered),
  )
  return ok ? { batch: body.batch, dialogues: items as ReviewDialogueItem[] } : null
}

/** One dialogue from GET /api/review/<secret>/dialogues/<id>, or null when the answer is not one. */
export function dialogueOf(body: unknown): ReviewDialogue | null {
  if (
    !isRecord(body) ||
    !isNumber(body.id) ||
    !isNumber(body.position) ||
    !isNumber(body.of) ||
    !isText(body.title) ||
    !isText(body.stop) ||
    !Array.isArray(body.lines)
  )
    return null
  const lines: unknown[] = body.lines
  const ok = lines.every(
    (l) =>
      isRecord(l) &&
      isNumber(l.id) &&
      isNumber(l.position) &&
      isText(l.speaker) &&
      isText(l.spoken) &&
      isText(l.written) &&
      isText(l.english) &&
      (l.spokenAudio === null || isText(l.spokenAudio)) &&
      (l.writtenAudio === null || isText(l.writtenAudio)) &&
      (l.answer === null || isAnswer(l.answer)) &&
      (l.note === null || isText(l.note)),
  )
  if (!ok) return null
  return {
    id: body.id,
    position: body.position,
    of: body.of,
    title: body.title,
    stop: body.stop,
    previous: isNumber(body.previous) ? body.previous : null,
    next: isNumber(body.next) ? body.next : null,
    lines: lines as ReviewLine[],
  }
}

const EDGE = /^([^\p{L}\p{N}]*)(.*?)([^\p{L}\p{N}]*)$/u

/**
 * A line's text as words for the line card, with punctuation kept outside
 * each word as the session does. The review has no word cards: every word is
 * plain text.
 */
export function plainWords(text: string): SessionWord[] {
  const words: SessionWord[] = []
  for (const chunk of text.split(/\s+/).filter(Boolean)) {
    const [, before = '', core = '', after = ''] = EDGE.exec(chunk) ?? []
    if (core === '') {
      const last = words.at(-1)
      if (last) last.after = `${last.after ?? ''} ${chunk}`
      else words.push({ text: chunk })
      continue
    }
    words.push({
      text: core,
      ...(before ? { before } : {}),
      ...(after ? { after } : {}),
    })
  }
  return words
}

/** The review line in the shape the session's line card draws. */
export function asSessionLine(line: ReviewLine): SessionLine {
  return {
    id: line.id,
    speaker: line.speaker,
    gloss: line.english,
    spokenAudio: line.spokenAudio ?? '',
    writtenAudio: line.writtenAudio ?? '',
    spoken: plainWords(line.spoken),
    written: plainWords(line.written),
  }
}

/** The line for a save that did not work. */
export function saveProblemOf(answer: ApiAnswer | null): string {
  if (answer === null) return NOT_SAVED_OFFLINE
  if (answer.status === 429) return NOT_SAVED_LIMIT
  if (answer.status === 404) return NOT_SAVED_GONE
  if (answer.status === 400 && isRecord(answer.body) && answer.body.field === 'note') return NOTE_TOO_LONG
  return NOT_SAVED
}

function usePageTitle(title: string) {
  useEffect(() => {
    const before = document.title
    document.title = `${title} | Aleksi`
    return () => {
      document.title = before
    }
  }, [title])
}

/** The one plain page for a wrong, deleted or malformed link. */
export function BrokenLink() {
  usePageTitle(BROKEN_TITLE)
  return (
    <PageFrame back={PATHS.landing} backLabel="Back to Aleksi" contentTop="near">
      <h1 className={own.title}>{BROKEN_TITLE}</h1>
    </PageFrame>
  )
}

type Load<T> = { kind: 'loading' } | { kind: 'problem' } | { kind: 'broken' } | { kind: 'ready'; data: T }

function useReviewLoad<T>(path: string, read: (body: unknown) => T | null): Load<T> {
  const [load, setLoad] = useState<Load<T>>({ kind: 'loading' })
  const first = useRef<Promise<Load<T>> | null>(null)
  useEffect(() => {
    let active = true
    first.current ??= callApi(path, 'GET').then((answer): Load<T> => {
      if (answer?.status === 404) return { kind: 'broken' }
      const data = answer?.status === 200 ? read(answer.body) : null
      return data ? { kind: 'ready', data } : { kind: 'problem' }
    })
    void first.current.then((next) => {
      if (active) setLoad(next)
    })
    return () => {
      active = false
    }
  }, [path, read])
  return load
}

function ReviewList({ token }: { token: string }) {
  const load = useReviewLoad(`/api/review/${token}`, overviewOf)
  usePageTitle(LIST_TITLE)
  if (load.kind === 'broken') return <BrokenLink />
  return (
    <PageFrame back={PATHS.landing} backLabel="Back to Aleksi" contentTop="near">
      <h1 className={own.title}>{LIST_TITLE}</h1>
      <div className={own.intro}>
        <p className={styles.summary}>{LIST_INTRO}</p>
        {load.kind === 'ready' && (
          <p className={styles.summary}>
            This is batch {load.data.batch} of 4, with {load.data.dialogues.length} dialogues in the order a
            learner meets them.
          </p>
        )}
      </div>
      {load.kind === 'loading' && <StatusLine tone="neutral">{LOADING}</StatusLine>}
      {load.kind === 'problem' && <StatusLine tone="problem">{NOT_LOADED}</StatusLine>}
      {load.kind === 'ready' && (
        <ul className={own.list} data-review="dialogues">
          {load.data.dialogues.map((item) => (
            <li key={item.id}>
              <a className={own.dialogueLink} href={reviewPagePath(token, item.id)}>
                <span className={own.dialogueTitle}>{item.title}</span>
                <span className={own.dialogueMeta}>
                  {item.stop}. {progressOf(item.answered, item.lines)}
                  {item.answered > 0 && item.answered < item.lines
                    ? `, ${String(item.answered)} of ${String(item.lines)} lines`
                    : ''}
                  .
                </span>
              </a>
            </li>
          ))}
        </ul>
      )}
    </PageFrame>
  )
}

type Save = (lineId: number, answer: ReviewAnswer, note: string | null) => Promise<ApiAnswer | null>

/** The three answers under one line, the note box for "Needs a fix" and the line's status. */
export function LineAnswer({ line, count, save }: { line: ReviewLine; count: number; save: Save }) {
  const [chosen, setChosen] = useState<ReviewAnswer | null>(line.answer)
  const [note, setNote] = useState(line.note ?? '')
  const [saving, setSaving] = useState(false)
  const [status, setStatus] = useState<{ text: string; tone: StatusTone }>({ text: '', tone: 'neutral' })
  const busy = useRef(false)
  const id = useId()
  const left = MAX_REVIEW_NOTE - characterCount(note)

  async function send(answer: ReviewAnswer) {
    // A tap while this line is saving is ignored, so two answers never race.
    if (busy.current) return
    setChosen(answer)
    const clean = cleanNote(note, answer)
    if (clean === undefined) {
      setStatus({ text: NOTE_TOO_LONG, tone: 'gentle' })
      return
    }
    busy.current = true
    setSaving(true)
    setStatus({ text: '', tone: 'neutral' })
    const result = await save(line.id, answer, clean)
    busy.current = false
    setSaving(false)
    if (result?.status === 200) setStatus({ text: SAVED, tone: 'neutral' })
    else setStatus({ text: saveProblemOf(result), tone: result?.status === 400 ? 'gentle' : 'problem' })
  }

  return (
    <div className={own.answer}>
      <div className={own.choices} role="group" aria-label={`Your answer for line ${String(count)}`}>
        {REVIEW_ANSWERS.map((answer) => (
          <Button
            key={answer}
            variant={chosen === answer ? 'primary' : 'secondary'}
            arrow={false}
            aria-pressed={chosen === answer}
            busy={saving && chosen === answer}
            busyLabel="Saving your answer."
            onClick={() => {
              void send(answer)
            }}
          >
            {ANSWER_LABELS[answer]}
          </Button>
        ))}
      </div>
      {chosen === 'needs_fix' && (
        <div className={feedback.field}>
          <label htmlFor={`${id}-note`} className={own.noteLabel}>
            {NOTE_LABEL}
          </label>
          <textarea
            id={`${id}-note`}
            className={`${feedback.textarea} ${own.note}`}
            value={note}
            maxLength={MAX_REVIEW_NOTE * 2}
            aria-describedby={`${id}-count`}
            onChange={(event) => {
              setNote(event.target.value)
            }}
          />
          <p id={`${id}-count`} className={left < 0 ? own.countOver : feedback.count}>
            {characterCount(note).toLocaleString('en-GB')} of {String(MAX_REVIEW_NOTE)} characters
          </p>
          <div>
            <Button
              variant="secondary"
              arrow={false}
              busy={saving}
              busyLabel="Saving your note."
              onClick={() => {
                void send('needs_fix')
              }}
            >
              {SAVE_NOTE}
            </Button>
          </div>
        </div>
      )}
      <StatusLine tone={status.tone}>{status.text}</StatusLine>
    </div>
  )
}

function ReviewDialoguePage({ token, dialogueId }: { token: string; dialogueId: number }) {
  const load = useReviewLoad(`/api/review/${token}/dialogues/${String(dialogueId)}`, dialogueOf)
  usePageTitle(load.kind === 'ready' ? load.data.title : LIST_TITLE)
  if (load.kind === 'broken') return <BrokenLink />
  const listPath = reviewPagePath(token)
  const save: Save = (lineId, answer, note) =>
    callApi(`/api/review/${token}/answers`, 'POST', { lineId, answer, note })
  return (
    <PageFrame back={listPath} backLabel="Back to the list of dialogues" contentTop="near">
      {load.kind === 'loading' && <StatusLine tone="neutral">{LOADING}</StatusLine>}
      {load.kind === 'problem' && <StatusLine tone="problem">{NOT_LOADED}</StatusLine>}
      {load.kind === 'ready' && (
        <>
          <div className={own.intro}>
            <h1 className={own.title}>{load.data.title}</h1>
            <p className={styles.quietText}>
              Dialogue {load.data.position} of {load.data.of}. {load.data.stop}.
            </p>
          </div>
          <ol className={own.lines} data-review="lines">
            {load.data.lines.map((line, index) => (
              <li key={line.id} className={own.line}>
                <LineCard
                  line={asSessionLine(line)}
                  showGloss
                  count={{ shown: index + 1, of: load.data.lines.length }}
                />
                <LineAnswer line={line} count={index + 1} save={save} />
              </li>
            ))}
          </ol>
          <ul className={styles.links}>
            <li>
              <a className={styles.link} href={listPath}>
                Back to the list
              </a>
            </li>
            {load.data.next !== null && (
              <li>
                <a className={styles.link} href={reviewPagePath(token, load.data.next)}>
                  Next dialogue
                </a>
              </li>
            )}
          </ul>
        </>
      )}
    </PageFrame>
  )
}

/** Every page under /review/: the list, one dialogue, or the plain broken link page. */
export function ReviewLinkPage({ path }: { path: string }) {
  const place = reviewPlaceOf(path)
  if (place.kind === 'list') return <ReviewList token={place.token} />
  if (place.kind === 'dialogue')
    return <ReviewDialoguePage token={place.token} dialogueId={place.dialogueId} />
  return <BrokenLink />
}
