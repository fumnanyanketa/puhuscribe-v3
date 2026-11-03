import { useId, useRef, useState } from 'react'
import { Sheet } from '../components/Sheet.tsx'
import { IslandCard, shownLines, tagText } from '../island/IslandCard.tsx'
import { IslandStep } from '../island/IslandStep.tsx'
import islandStyles from '../island/Island.module.css'
import { islandStop, type IslandEntry } from '../lib/islands.ts'
import { RoadPicture } from '../road/RoadPicture.tsx'
import { RoadTop } from '../road/RoadTop.tsx'
import { homeView, todayInfoFrom } from '../road/home-view.ts'
import { roadFixture } from '../road/road-fixture.ts'
import roadStyles from '../screens/RoadScreen.module.css'

// A DESIGN PAGE FOR LOCAL DEVELOPMENT ONLY (language islands), at /sample/island, like
// /sample/hear-it: it exists only in development and in builds made with VITE_DESIGN_REFERENCE=1
// (src/main.tsx). It shows the island step and the island card with the real components and the
// approved lines, without a database: nothing is saved and nothing is sent. The example learner is
// the approved mockup's Ada from Nigeria, living in Espoo, after stop 5.
//
// /sample/island         the "Use it" step of stop 1 (fill the gaps, then hear and say)
// /sample/island?stop=N  the step of another stop
// /sample/island?view=card  the road with the "Your island" card open

const ADA: IslandEntry[] = [
  { stop: 1, choice: 0, name: 'Ada' },
  { stop: 2, choice: 1 },
  { stop: 3, choice: 0 },
  { stop: 4, choice: 0 },
  { stop: 5, choice: 0 },
]

const ROAD = homeView(
  roadFixture({ 1: 4, 2: 4, 3: 4, 4: 4, 5: 4 }),
  todayInfoFrom({ signedIn: true, today: 'start' }),
  null,
)

function CardSample() {
  const [open, setOpen] = useState(true)
  const tag = useRef<HTMLButtonElement>(null)
  const title = useId()
  return (
    <main className={roadStyles.screen}>
      <div className={roadStyles.world}>
        <div className={roadStyles.pictureBox}>
          <RoadPicture
            signs={ROAD.signs}
            markerAt={ROAD.markerAt}
            travelledTo={ROAD.travelledTo}
            lowest={420}
          />
        </div>
      </div>
      <div className={roadStyles.top}>
        <RoadTop pieces={ROAD.pieces} letter="A" />
        <div className={islandStyles.tagRow}>
          <button
            ref={tag}
            type="button"
            className={islandStyles.tag}
            aria-haspopup="dialog"
            onClick={() => {
              setOpen(true)
            }}
          >
            {tagText(shownLines(ADA).length)}
          </button>
        </div>
      </div>
      <Sheet
        open={open}
        labelledBy={title}
        returnFocus={tag}
        onClose={() => {
          setOpen(false)
        }}
      >
        <IslandCard titleId={title} lines={ADA} open={[1, 2, 3, 4, 5, 6]} onChange={() => undefined} />
      </Sheet>
    </main>
  )
}

export default function IslandSample() {
  const params = new URLSearchParams(window.location.search)
  if (params.get('view') === 'card') return <CardSample />
  const stop = islandStop(Number(params.get('stop') ?? '1')) ?? islandStop(1)
  if (!stop) return <p>No approved island lines are loaded.</p>
  return (
    <IslandStep
      key={stop.stop}
      stop={stop}
      frame={{ step: 'Use it', steps: ['Hear it, say it', 'Understand it', 'Recap', 'Use it'] }}
      leaveHref="/sample/island"
      onSave={() => Promise.resolve(true)}
      onSkip={stop.optional ? () => undefined : undefined}
    />
  )
}
