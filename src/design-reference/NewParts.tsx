import { useRef, useState, type ReactNode } from 'react'
import { Button } from '../components/Button.tsx'
import { FinnishLine } from '../components/FinnishLine.tsx'
import { Landscape, RoadScene } from '../components/Landscape.tsx'
import { PlayControl } from '../components/PlayControl.tsx'
import { RecordControl, Wave } from '../components/RecordControl.tsx'
import { Sheet } from '../components/Sheet.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { SproutMark } from '../components/Wordmark.tsx'
import type { CardView } from '../road/RoadCard.tsx'
import { RoadCard } from '../road/RoadCard.tsx'
import { RoadPicture } from '../road/RoadPicture.tsx'
import { RoadTop } from '../road/RoadTop.tsx'
import { homeView, todayInfoFrom } from '../road/home-view.ts'
import { ROAD_DAY_ONE, ROAD_MID, roadFixture } from '../road/road-fixture.ts'
import { ConsentSheet } from '../screens/ConsentSheet.tsx'
import { FirstLessonTip } from '../screens/FirstLessonTip.tsx'
import { CrashScreen } from '../components/CrashBoundary.tsx'
import { OfflineScreen } from '../screens/OfflineScreen.tsx'
import { RECORD_HINTS } from '../screens/SayIt.tsx'
import voice from '../screens/Voice.module.css'
import { SPOKEN_EXAMPLE, TONE, WRITTEN_EXAMPLE, SECOND_TONE } from './reference-content.ts'
import styles from './DesignReference.module.css'

// The parts job 19-redesign added to the reference page (statement 8): the
// landscape band and the road scene, panels, the road in each state and each
// sign state, the card at the bottom in each state, the line card with the
// first lesson tip, the sheets, the progress bars and the loading and offline
// screens. Finnish here is only the PRD example, marked "Sample, not reviewed."

function Section({ id, title, children }: { id: string; title: string; children: ReactNode }) {
  return (
    <section className={styles.section} aria-labelledby={id}>
      <h2 id={id} className={styles.sectionTitle}>
        {title}
      </h2>
      {children}
    </section>
  )
}

const noop = () => undefined

function Picture({ view, label }: { view: ReturnType<typeof homeView>; label: string }) {
  return (
    <figure className={styles.roadFigure}>
      <div className={styles.roadBox} data-land={view.evening ? 'evening' : undefined}>
        <RoadPicture
          signs={view.signs}
          markerAt={view.markerAt}
          travelledTo={view.travelledTo}
          lowest={340}
          evening={view.evening}
        />
      </div>
      <figcaption>{label}</figcaption>
    </figure>
  )
}

const VISITOR = todayInfoFrom({ signedIn: false, ended: false })
const MID = homeView(ROAD_MID, todayInfoFrom({ signedIn: true, today: 'continue' }), null)
const FINISHED = homeView(
  roadFixture({ 1: 4, 2: 4, 3: 4 }),
  todayInfoFrom({ signedIn: true, today: 'start' }),
  null,
)
const EVENING = homeView(
  ROAD_MID,
  todayInfoFrom({
    signedIn: true,
    today: 'all_done',
    nextReview: { today: '2026-11-01', day: '2026-11-02' },
  }),
  null,
)
const DAY_ONE = homeView(ROAD_DAY_ONE, VISITOR, null)

const [FIRST, SECOND] = ROAD_MID
const THIRD = ROAD_MID[2]
const FOURTH = ROAD_MID[3]

const CARDS: [string, CardView][] = [
  ['Day one', DAY_ONE.card],
  ['Start or continue', { kind: 'lesson', stop: THIRD, action: 'Continue' }],
  ['Review waiting', { kind: 'review', count: 14 }],
  ['Stop finished', { kind: 'stop-finished', done: SECOND, next: THIRD }],
  ['Done for today', { kind: 'done', line: 'Your next review is tomorrow.' }],
  ['A message', { kind: 'message', text: 'Today’s session is not ready yet. Please come back later.' }],
]

function Demo({ label, children }: { label: string; children: ReactNode }) {
  return (
    <figure className={styles.state}>
      {children}
      <figcaption>{label}</figcaption>
    </figure>
  )
}

export function NewParts() {
  const [leave, setLeave] = useState(false)
  const [consent, setConsent] = useState(false)
  const [tip, setTip] = useState(false)
  const region = useRef<HTMLDivElement>(null)
  const opener = useRef<HTMLButtonElement>(null)
  return (
    <>
      <Section id="landscape" title="Landscape and panels">
        <p className={styles.lead}>
          The band sits behind the top of every screen except the road, and fades into the wash. The road
          scene is the home screen’s picture, in the day set and the evening set. Both are inline drawings
          with no image file.
        </p>
        <div className={styles.bandBox}>
          <Landscape />
        </div>
        <div className={styles.sceneRow}>
          <Demo label="Day">
            <RoadScene travelledTo={0.12} />
          </Demo>
          <Demo label="Evening">
            <RoadScene travelledTo={0.12} evening />
          </Demo>
        </div>
        <div className={styles.panelSample}>
          A milky panel: fill, edge, shadow and corner from the panel tokens.
        </div>
      </Section>

      <Section id="road" title="The road">
        <p className={styles.lead}>
          Five signs at a time. A sign is a list item, never a button. The fixture stops are test data from
          docs/curriculum-a1.md and are never shown to a learner.
        </p>
        <div className={styles.sceneRow}>
          <Picture view={DAY_ONE} label="Day one: stop 1 is current" />
          <Picture view={MID} label="Stops 1 and 2 done, stop 3 current" />
          <Picture view={FINISHED} label="Stop finished: the next sign is lit in peach" />
          <Picture view={EVENING} label="Done for today: the evening sky" />
        </div>
        <h3 className={styles.subTitle}>The top</h3>
        <div className={styles.roadTop}>
          <RoadTop pieces={MID.pieces} letter="M" />
        </div>
        <div className={styles.roadTop}>
          <RoadTop pieces={DAY_ONE.pieces} letter={null} />
        </div>
        <h3 className={styles.subTitle}>The card at the bottom</h3>
        <div className={styles.cardList}>
          {CARDS.map(([label, card]) => (
            <Demo key={label} label={label}>
              <RoadCard
                view={card}
                onStart={noop}
                onContinue={noop}
                starting={false}
                problem={null}
                startRef={{ current: null }}
              />
            </Demo>
          ))}
        </div>
        <p className={styles.lead}>
          Sign states, in words: done, current, next and later. The names are {FIRST.name}, {FOURTH.name} and
          the rest.
        </p>
      </Section>

      <Section id="line-card" title="Line card and first lesson tip">
        <p className={styles.lead}>
          Spoken line in a soft box with a mint play button, written line in slate, two dots joined by a
          dotted line. Changed words are peach on a peach wash.
        </p>
        <div className={styles.cardSample} ref={region}>
          <FinnishLine
            cardNote="Sample, not reviewed."
            spoken={SPOKEN_EXAMPLE}
            written={WRITTEN_EXAMPLE}
            spokenControl={<PlayControl src={TONE} what="the spoken line" />}
            writtenControl={
              <PlayControl src={SECOND_TONE} what="the written line" size="small" tone="written" />
            }
          />
        </div>
        <p className={styles.lead}>The tip on a learner’s first lesson, as a live example.</p>
        <Button
          variant="secondary"
          ref={opener}
          onClick={() => {
            setTip(true)
          }}
        >
          Show the tip
        </Button>
        {tip && (
          <FirstLessonTip
            region={region}
            restoreFocusTo={opener}
            onClose={() => {
              setTip(false)
            }}
          />
        )}
      </Section>

      <Section id="sheets" title="Sheets">
        <p className={styles.lead}>
          Bottom sheets are native dialogs: focus goes in, stays in, and returns to the button that opened
          them.
        </p>
        <div className={styles.stateRow}>
          <Button
            variant="secondary"
            onClick={() => {
              setLeave(true)
            }}
          >
            Open the leave sheet
          </Button>
          <Button
            variant="secondary"
            onClick={() => {
              setConsent(true)
            }}
          >
            Open the speaking sheet
          </Button>
        </div>
        <Sheet
          open={leave}
          labelledBy="ref-leave-title"
          onClose={() => {
            setLeave(false)
          }}
        >
          <h2 id="ref-leave-title" className={styles.subTitle}>
            Leave this lesson?
          </h2>
          <p className={styles.lead}>You can carry on later from here.</p>
          <Button
            block
            data-sheet-focus
            onClick={() => {
              setLeave(false)
            }}
          >
            Keep going
          </Button>
          <Button
            variant="secondary"
            block
            onClick={() => {
              setLeave(false)
            }}
          >
            Leave
          </Button>
        </Sheet>
        <ConsentSheet
          open={consent}
          region={null}
          busy={false}
          onTurnOn={() => {
            setConsent(false)
          }}
          onNotNow={() => {
            setConsent(false)
          }}
        />
      </Section>

      <Section id="say-results" title="Say it, each state">
        <p className={styles.lead}>
          The record button as Say it words it, while listening, with a clear result and with a try again
          note.
        </p>
        <div className={styles.sceneRow}>
          <Demo label="Ready">
            <RecordControl state="ready" hints={RECORD_HINTS} />
          </Demo>
          <Demo label="Listening">
            <RecordControl state="recording" seconds={3} hints={RECORD_HINTS} />
          </Demo>
          <Demo label="Clear">
            <section className={voice.clearCard} aria-label="A clear result">
              <p className={voice.clearLine}>
                <span className={voice.checkCircle} aria-hidden="true">
                  <svg viewBox="0 0 24 24" focusable="false">
                    <path d="M5 12.5l4.5 4.5L19 7.5" />
                  </svg>
                </span>
                Yes, that was clear.
              </p>
              <Wave />
              <div className={voice.recordingControls}>
                <Button variant="secondary">Play mine</Button>
                <Button variant="secondary">Try again</Button>
              </div>
            </section>
          </Demo>
          <Demo label="Try again">
            <StatusLine tone="gentle">Listen to the line once more, then try again.</StatusLine>
          </Demo>
        </div>
      </Section>

      <Section id="marks" title="Wave, brand mark, loading and no connection">
        <div className={styles.stateRow}>
          <Demo label="Wave, mint">
            <Wave />
          </Demo>
          <Demo label="Wave, recording">
            <Wave tone="recording" />
          </Demo>
          <Demo label="Brand mark">
            <SproutMark size={56} />
          </Demo>
        </div>
        <div className={styles.stack}>
          <StatusLine tone="neutral">Line 2 of 8.</StatusLine>
          <StatusLine tone="gentle">Listen to the line once more, then try again.</StatusLine>
          <StatusLine tone="problem">
            Your progress was not saved. Check your internet connection, then try again.
          </StatusLine>
        </div>
        <div className={styles.offlineBox}>
          <OfflineScreen where="road" embedded />
        </div>
        <div className={styles.offlineBox} data-crash-screen="">
          <CrashScreen embedded />
        </div>
      </Section>
    </>
  )
}
