import { useState } from 'react'
import { Button } from '../components/Button.tsx'
import { PlayControl } from '../components/PlayControl.tsx'
import { GREETING_AUDIO, PORTRAIT_RATIO, PORTRAIT_WIDTHS, portraitSrc } from '../lib/aleksi-intro.ts'
import styles from './AleksiIntro.module.css'

// Meeting Aleksi (fast route aleksi-intro, owner approved 4 November 2026): the
// "call card" mockup's left phone, built with the app's tokens. A tall photo
// card with his name, the white bubble with his greeting in Finnish and English
// and a play button, one line, then "Nice to meet you". The greeting tries once
// to play when the screen opens; when the browser blocks that (iPhones do), the
// play button plays it. Nothing here sends anything or makes an account.

/** Aleksi's spoken greeting, the one Finnish line on this screen (listed for the native reviewer). */
export const GREETING_FI = 'Moi! Mä oon Aleksi.'
export const GREETING_EN = 'Hi! I’m Aleksi.'
export const INTRO_LINE = 'I’ll be with you on your Finnish journey.'
export const PORTRAIT_ALT = 'Aleksi, your Finnish tutor'

const middle = PORTRAIT_WIDTHS[1]

export function AleksiIntro({ onMeet }: { onMeet: () => void }) {
  const [speaking, setSpeaking] = useState(false)
  return (
    <main className={styles.screen}>
      <div className={styles.photo}>
        <img
          className={styles.image}
          src={portraitSrc(middle)}
          srcSet={PORTRAIT_WIDTHS.map((width) => `${portraitSrc(width)} ${String(width)}w`).join(', ')}
          sizes="(min-width: 30rem) 448px, calc(100vw - 32px)"
          width={middle}
          height={Math.round((middle * PORTRAIT_RATIO.height) / PORTRAIT_RATIO.width)}
          alt={PORTRAIT_ALT}
          decoding="async"
          fetchPriority="high"
        />
        <div className={styles.nameRow}>
          <h1 className={styles.name}>Aleksi</h1>
          <span className={styles.wave} data-speaking={speaking ? 'yes' : undefined} aria-hidden="true">
            <i />
            <i />
            <i />
            <i />
          </span>
        </div>
      </div>
      <div className={styles.body}>
        <div className={styles.bubble}>
          <div className={styles.bubbleText}>
            <p className={styles.finnish} lang="fi">
              {GREETING_FI}
            </p>
            <p className={styles.english}>{GREETING_EN}</p>
          </div>
          <PlayControl
            src={GREETING_AUDIO}
            what="Aleksi’s greeting"
            size="small"
            tryOnOpen
            onPlayingChange={setSpeaking}
          />
        </div>
        <p className={styles.line}>{INTRO_LINE}</p>
      </div>
      <div className={styles.actions}>
        <Button block onClick={onMeet}>
          Nice to meet you
        </Button>
        <p className={styles.note}>No account needed to start.</p>
      </div>
    </main>
  )
}
