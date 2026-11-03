import { useEffect, useLayoutEffect, useRef, useState } from 'react'
import { SCENE_WIDTH } from '../components/landscape-geometry.ts'
import { fitSigns } from '../lib/road-state.ts'
import { homeView, todayInfoFrom } from '../road/home-view.ts'
import { RoadCard } from '../road/RoadCard.tsx'
import { RoadPicture } from '../road/RoadPicture.tsx'
import { RoadTop } from '../road/RoadTop.tsx'
import screen from '../screens/RoadScreen.module.css'
import styles from './HeroRoad.module.css'
import { VISITOR_ROAD } from './road-stops.ts'

// The hero phone's screen (job 17-landing-page): the app's own road screen, drawn by the app's own
// road components, as a new visitor first sees it, at stop 1 with nothing done. It plays the same
// opening animation the home screen plays, once, when the page opens. It is decoration: nothing in
// it can be focused or pressed (inert), screen readers skip it (the hero picture's description is
// on the frame), and it makes no data call. With reduced motion on it shows the end state at once,
// as the app does.
//
// The screen is drawn at the app's own phone size, 375 x 812, and scaled down to the frame, so the
// road looks exactly as it does in the app.

const SCREEN_HEIGHT = 812
const MOST_SIGNS = 5

function reducedMotion(): boolean {
  try {
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches
  } catch {
    return false
  }
}

const noop = () => undefined

export function HeroRoad() {
  // The road is drawn only in the browser, so the phone's setting can be read at once.
  const [playing, setPlaying] = useState(() => !reducedMotion())
  const [lowest, setLowest] = useState(400)
  const [signGap, setSignGap] = useState(0)
  const picture = useRef<HTMLDivElement>(null)
  const cardBox = useRef<HTMLDivElement>(null)
  const startRef = useRef<HTMLButtonElement>(null)

  const view = homeView(VISITOR_ROAD, todayInfoFrom(null), null)
  const shown = fitSigns(view.signs, view.markerAt, MOST_SIGNS)

  // Where the signs may stand, measured once before the first paint, as the road screen measures it:
  // above the card, with the gap the tallest board needs. Layout sizes, so the frame's scaling and
  // the animation do not change them.
  useLayoutEffect(() => {
    const box = picture.current?.firstElementChild
    if (!(box instanceof HTMLElement)) return
    const unit = box.offsetWidth / SCENE_WIDTH
    if (unit <= 0) return
    const cardHeight = cardBox.current?.offsetHeight ?? 230
    setLowest(Math.max(260, (SCREEN_HEIGHT - cardHeight - 24 - box.offsetTop) / unit))
    const boards = [...box.querySelectorAll('ol > li')].map(
      (item) =>
        (item.firstElementChild?.querySelector('[aria-hidden="true"]') as HTMLElement | null)?.offsetHeight ??
        0,
    )
    const tallest = Math.max(0, ...boards)
    setSignGap(Math.ceil((tallest + 22) / (box.offsetWidth / 280)))
  }, [])

  // The opening animation always ends, even if a browser never fires its end.
  useEffect(() => {
    if (!playing) return undefined
    const timer = setTimeout(() => {
      setPlaying(false)
    }, 6000)
    return () => {
      clearTimeout(timer)
    }
  }, [playing])

  return (
    <div className={styles.viewport} aria-hidden="true" inert>
      <div className={`${screen.screen} ${styles.screen}`} data-intro={playing ? 'on' : undefined}>
        <div className={screen.world}>
          <div className={screen.pictureBox} ref={picture}>
            <RoadPicture
              signs={shown.signs}
              markerAt={shown.markerAt}
              travelledTo={view.travelledTo}
              lowest={lowest}
              signGap={signGap}
              shifts={{}}
              pins={false}
              evening={view.evening}
              intro={playing}
            />
          </div>
        </div>
        <div className={screen.top}>
          <RoadTop pieces={view.pieces} letter={null} />
        </div>
        <div
          className={`${screen.card} ${styles.card}`}
          ref={cardBox}
          onAnimationEnd={(event) => {
            if (event.target === event.currentTarget) setPlaying(false)
          }}
        >
          <RoadCard
            view={view.card}
            starting={false}
            problem={null}
            startRef={startRef}
            onStart={noop}
            onContinue={noop}
          />
        </div>
      </div>
    </div>
  )
}
