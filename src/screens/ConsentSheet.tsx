import { useId, useRef, type ReactNode } from 'react'
import { Button } from '../components/Button.tsx'
import { Sheet } from '../components/Sheet.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { PATHS } from '../lib/app-paths.ts'
import { voiceNotice } from '../lib/voice-consent.ts'
import styles from './ConsentSheet.module.css'

// The speaking consent sheet (job 19-redesign, statement 29, owner's call 10
// answered "as drawn" on 1 November 2026): a bottom sheet that shows only its
// title ("Say it out loud"), a "How it works" link, "Turn on" and "Not now".
// The details are on the privacy page, whose "Your voice" section "How it
// works" opens (in a new tab, so the lesson stays where it is); the full text
// of job 10 (src/lib/voice-consent.ts) stays unchanged there.
//
// The rules of job 10 still hold. Nothing asks for the microphone before "Turn
// on" is pressed (the recorder module does that later, for the first
// recording). "Turn on" records one voice_processing granted row. The box
// "Keep my recordings" is never ticked for the learner and is not on this sheet:
// the learner can turn it on in Voice settings. "Not now" lets the learner say
// each line without feedback, and Escape does the same, because it records
// nothing. Withdrawing is as easy as agreeing: Voice settings turns it off.

export const CONSENT_TITLE = 'Say it out loud'
export const HOW_IT_WORKS = 'How it works'
/** The anchor of the privacy page's voice section. */
export const VOICE_SECTION = 'privacy-voice'

interface ConsentSheetProps {
  open: boolean
  /** The EU country of the speech service, for the accessible name of "Turn on". */
  region: string | null
  busy: boolean
  /** A problem with saving the choice, shown inside the sheet. */
  problem?: ReactNode
  onTurnOn: () => void
  onNotNow: () => void
}

export function ConsentSheet({ open, region, busy, problem, onTurnOn, onNotNow }: ConsentSheetProps) {
  const titleId = useId()
  const title = useRef<HTMLHeadingElement>(null)
  const notice = voiceNotice(region)
  return (
    <Sheet open={open} labelledBy={titleId} onClose={onNotNow} initialFocus={title}>
      <h2 id={titleId} ref={title} tabIndex={-1} className={styles.title}>
        {CONSENT_TITLE}
      </h2>
      <a
        className={styles.how}
        href={`${PATHS.privacy}#${VOICE_SECTION}`}
        target="_blank"
        rel="noopener"
        aria-label={`${HOW_IT_WORKS}, opens in a new tab`}
      >
        {HOW_IT_WORKS}
      </a>
      {problem && <StatusLine tone="problem">{problem}</StatusLine>}
      <div className={styles.buttons}>
        <Button
          block
          busy={busy}
          busyLabel="Saving your choice."
          aria-label={notice.turnOn}
          onClick={onTurnOn}
        >
          Turn on
        </Button>
        <Button block variant="secondary" onClick={onNotNow}>
          {notice.notNow}
        </Button>
      </div>
    </Sheet>
  )
}
