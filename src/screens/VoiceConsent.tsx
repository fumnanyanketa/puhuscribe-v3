import { useId } from 'react'
import { voiceNotice } from '../lib/voice-consent.ts'
import styles from './Voice.module.css'

// The voice consent text (factory/jobs/10-speaking-feedback/spec.md, "Done
// when" 1), with its one unticked box. The buttons sit with the screen that
// shows it: Say it puts them in the session's action area, Voice settings
// under the text. The text itself lives in src/lib/voice-consent.ts with its
// version label.

interface VoiceConsentProps {
  /** The EU country of the speech service, from the Worker's settings. */
  region: string | null
  keep: boolean
  onKeepChange: (keep: boolean) => void
  /** The heading level: the page title on Say it, a section heading in Voice settings. */
  headingLevel: 1 | 2
}

export function VoiceConsent({ region, keep, onKeepChange, headingLevel }: VoiceConsentProps) {
  const notice = voiceNotice(region)
  const boxId = useId()
  const Heading = headingLevel === 1 ? 'h1' : 'h2'
  return (
    <section className={styles.consent} aria-labelledby={`${boxId}-heading`}>
      <Heading id={`${boxId}-heading`} className={headingLevel === 1 ? styles.title : styles.sectionTitle}>
        {notice.heading}
      </Heading>
      {notice.paragraphs.map((text) => (
        <p key={text} className={styles.text}>
          {text}
        </p>
      ))}
      <div className={styles.box}>
        <input
          id={boxId}
          type="checkbox"
          className={styles.check}
          checked={keep}
          onChange={(event) => {
            onKeepChange(event.target.checked)
          }}
        />
        <label htmlFor={boxId} className={styles.boxLabel}>
          {notice.keepBox}
        </label>
      </div>
      <p className={styles.text}>{notice.changeLater}</p>
    </section>
  )
}
