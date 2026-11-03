import { useCallback, useState } from 'react'
import line from '../components/FinnishLine.module.css'
import { SPOKEN_GROUP, WRITTEN_GROUP } from '../components/FinnishLine.tsx'
import { PlayControl } from '../components/PlayControl.tsx'
import type { FilledLine, LinePiece } from '../lib/islands.ts'
import { Meaning } from '../screens/LineCard.tsx'
import screens from '../screens/Screens.module.css'
import styles from './Island.module.css'

// One island line on the "Use it" step (language islands), drawn like every lesson's line card: the
// spoken line in its soft box with a mint play button, the written line under it in slate with its
// own, the two dots joined by a dotted line at the left, and the English under a dashed line. The
// learner's own part (the choice and the name) is peach, as drawn, and named for screen readers.

export const ISLAND_AUDIO = { spoken: 'your line, spoken', written: 'your line, written' }

function Pieces({ pieces }: { pieces: readonly LinePiece[] }) {
  return pieces.map((piece, index) =>
    piece.mine ? (
      <span key={index} className={styles.mine}>
        {piece.text}
      </span>
    ) : (
      <span key={index}>{piece.text}</span>
    ),
  )
}

export function IslandLine({ filled }: { filled: FilledLine }) {
  const [spokenPlaying, setSpokenPlaying] = useState(false)
  const [writtenPlaying, setWrittenPlaying] = useState(false)
  const spokenChange = useCallback((playing: boolean) => {
    setSpokenPlaying(playing)
  }, [])
  const writtenChange = useCallback((playing: boolean) => {
    setWrittenPlaying(playing)
  }, [])
  const now = spokenPlaying || writtenPlaying
  return (
    <div className={now ? `${screens.card} ${screens.cardNow}` : screens.card} data-island-stop={filled.stop}>
      <div className={line.pair}>
        <div className={line.rail} aria-hidden="true">
          <span className={line.dotSpoken} />
          <span className={line.connector} />
          <span className={line.dotWritten} />
        </div>
        <div className={line.rows}>
          <div className={line.spokenRow} role="group" aria-label={SPOKEN_GROUP}>
            <p className={line.spokenLine} lang="fi">
              <Pieces pieces={filled.spoken} />
            </p>
            <PlayControl src={filled.spokenAudio} what={ISLAND_AUDIO.spoken} onPlayingChange={spokenChange} />
          </div>
          <div className={line.writtenRow} role="group" aria-label={WRITTEN_GROUP}>
            <p className={line.writtenLine} lang="fi">
              <Pieces pieces={filled.written} />
            </p>
            <PlayControl
              src={filled.writtenAudio}
              what={ISLAND_AUDIO.written}
              size="small"
              tone="written"
              onPlayingChange={writtenChange}
            />
          </div>
        </div>
      </div>
      <Meaning english={filled.english} />
    </div>
  )
}
