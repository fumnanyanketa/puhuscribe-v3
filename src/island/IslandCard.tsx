import { useState } from 'react'
import { MicIcon } from '../components/RecordControl.tsx'
import { PlayControl, PlayIcon } from '../components/PlayControl.tsx'
import {
  CLOSING,
  endsWithClosing,
  fillLine,
  islandAudio,
  islandStop,
  plainLine,
  type FilledLine,
  type IslandEntry,
} from '../lib/islands.ts'
import styles from './Island.module.css'
import { useLongRecording, usePlaylist } from './use-island-audio.ts'

// The island card (language islands), as in the approved mockup: "Your island", every line the
// learner has added in road order, spoken with a play button and written under it, then the question
// back "Entä sä?", and "Play all" and "Say it all". "Change a line" lets the learner change any line. A stop the learner has
// finished without adding its line offers "Add your line". It opens in a sheet from the "Your island"
// tag on the road. Nothing personal is sent anywhere from here: the clips are the same files for
// everyone, and the recording of "Say it all" stays in this page's memory.

interface IslandCardProps {
  titleId: string
  lines: readonly IslandEntry[]
  /** Stops whose line the learner may add now. */
  open: readonly number[]
  onChange: (stop: number) => void
}

export interface ShownLine {
  entry: IslandEntry
  filled: FilledLine
}

/** The learner's lines that the approved data can make, in road order. */
export function shownLines(lines: readonly IslandEntry[]): ShownLine[] {
  return [...lines]
    .sort((a, b) => a.stop - b.stop)
    .flatMap((entry) => {
      const stop = islandStop(entry.stop)
      const filled = stop ? fillLine(stop, entry.choice, entry.name ?? '') : null
      return filled ? [{ entry, filled }] : []
    })
}

/** "Your island · 5 lines", the tag on the road, with the drawing's middle dot. */
export function tagText(count: number): string {
  if (count === 0) return 'Your island'
  return `Your island · ${String(count)} ${count === 1 ? 'line' : 'lines'}`
}

export function IslandCard({ titleId, lines, open, onChange }: IslandCardProps) {
  const shown = shownLines(lines)
  const missing = open.filter((stop) => !lines.some((line) => line.stop === stop))
  const last = shown.at(-1)
  const closingInLine = last ? endsWithClosing(last.filled) : false
  // "Change a line" shows a Change button by every line; the card is drawn without them otherwise.
  const [changing, setChanging] = useState(false)
  const playlist = usePlaylist()
  const mine = useLongRecording()
  const sources = [
    ...shown.map((line) => line.filled.spokenAudio),
    ...(closingInLine ? [] : [islandAudio(CLOSING.audio.spoken)]),
  ]

  return (
    <>
      <h2 id={titleId} className={styles.islandTitle}>
        Your island
      </h2>
      {shown.length === 0 && missing.length === 0 && (
        <p className={styles.quietLine}>Your island starts at the end of stop 1.</p>
      )}
      {shown.length > 0 && (
        <ol className={styles.lines}>
          {shown.map(({ entry, filled }) => {
            const stop = islandStop(entry.stop)
            return (
              <li key={entry.stop} className={styles.line} data-island-line={entry.stop}>
                <div className={styles.lineSpoken}>
                  <p lang="fi">{plainLine(filled.spoken)}</p>
                  <PlayControl
                    src={filled.spokenAudio}
                    what={`your line for stop ${String(entry.stop)}`}
                    size="mini"
                  />
                </div>
                <div className={styles.lineWritten}>
                  <p lang="fi">{plainLine(filled.written)}</p>
                  {changing && (
                    <button
                      type="button"
                      className={styles.change}
                      aria-label={`Change your line for stop ${String(entry.stop)}, ${stop?.title ?? ''}`}
                      onClick={() => {
                        onChange(entry.stop)
                      }}
                    >
                      Change
                    </button>
                  )}
                </div>
              </li>
            )
          })}
        </ol>
      )}
      {shown.length > 0 && !closingInLine && (
        <p className={styles.ask} lang="fi">
          {CLOSING.spoken}
        </p>
      )}
      {missing.map((stop) => (
        <button
          key={stop}
          type="button"
          className={styles.add}
          onClick={() => {
            onChange(stop)
          }}
        >
          Add your line for stop {stop}, {islandStop(stop)?.title}
        </button>
      ))}
      {shown.length > 0 && (
        <div className={styles.two}>
          <button
            type="button"
            className={playlist.playing ? `${styles.ghost} ${styles.ghostOn}` : styles.ghost}
            aria-pressed={playlist.playing}
            onClick={() => {
              if (playlist.playing) playlist.stop()
              else playlist.play(sources)
            }}
          >
            <span className={`${styles.icon} ${styles.playIcon}`} aria-hidden="true">
              <PlayIcon />
            </span>
            {playlist.playing ? 'Stop' : 'Play all'}
          </button>
          <button
            type="button"
            className={mine.state === 'recording' ? `${styles.ghost} ${styles.ghostOn}` : styles.ghost}
            disabled={mine.state === 'unavailable'}
            aria-label={
              mine.state === 'recording' ? 'Stop recording' : 'Say it all, record yourself saying your island'
            }
            onClick={() => {
              if (mine.state === 'recording') mine.stop()
              else {
                playlist.stop()
                void mine.start()
              }
            }}
          >
            <span className={styles.icon} aria-hidden="true">
              <MicIcon />
            </span>
            {mine.state === 'recording' ? 'Stop' : 'Say it all'}
          </button>
        </div>
      )}
      {mine.hasRecording && mine.state === 'ready' && (
        <button type="button" className={styles.add} onClick={mine.playMine}>
          Play mine
        </button>
      )}
      {shown.length > 0 && (
        <button
          type="button"
          className={styles.add}
          aria-pressed={changing}
          onClick={() => {
            setChanging(!changing)
          }}
        >
          {changing ? 'Done changing' : 'Change a line'}
        </button>
      )}
      {mine.problem === 'denied' && (
        <p className={styles.quietLine}>
          Microphone access is off. You can turn it on in your browser settings.
        </p>
      )}
      {mine.state === 'unavailable' && shown.length > 0 && (
        <p className={styles.quietLine}>Recording is not available in this browser.</p>
      )}
    </>
  )
}
