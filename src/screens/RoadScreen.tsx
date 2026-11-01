import { useCallback, useEffect, useLayoutEffect, useRef, useState } from 'react'
import { PATHS } from '../lib/app-paths.ts'
import { accountKindOf } from './save-note.ts'
import { noticeFrom } from '../lib/account-notice.ts'
import { accountLetter } from '../lib/road-state.ts'
import { callApi, isRecord } from '../lib/api.ts'
import { loadRoad } from '../lib/road-data.ts'
import type { RoadView } from '../lib/road-types.ts'
import { homeView, todayInfoFrom, type TodayInfo } from '../road/home-view.ts'
import { LoadingMark } from '../road/LoadingMark.tsx'
import { RoadCard } from '../road/RoadCard.tsx'
import { RoadPicture } from '../road/RoadPicture.tsx'
import { RoadTop } from '../road/RoadTop.tsx'
import { LOADING, NOT_STARTED } from './road-copy.ts'
import { OfflineScreen } from './OfflineScreen.tsx'
import styles from './RoadScreen.module.css'

// The home screen: the road to the A1 sun (job 19-redesign, statements 10 to
// 20). It replaces the front door. Loading it creates nothing: only pressing
// "Start" sends POST /api/guest. It reads the stops through loadRoad() and what
// today holds from the existing GET /api/today, and, when a learner is signed
// in, the letter for the account button from GET /api/me, once, after the road
// is drawn.

type Home = { kind: 'loading' } | { kind: 'offline' } | { kind: 'ready'; road: RoadView; today: TodayInfo }

/** The sign in cookie only exists after "Start"; without an answer the page offers Start, which finds a guest already on this device. */
async function loadHome(): Promise<Home> {
  const [todayAnswer, road] = await Promise.all([callApi('/api/today', 'GET'), loadRoad()])
  if (!road) return { kind: 'offline' }
  const today = todayAnswer?.status === 200 ? todayInfoFrom(todayAnswer.body) : todayInfoFrom(null)
  return { kind: 'ready', road, today }
}

/** The card's room at the bottom, in px, until it is measured. */
const CARD_ESTIMATE = 230

export function RoadScreen() {
  const [home, setHome] = useState<Home>({ kind: 'loading' })
  const [playing, setPlaying] = useState(false)
  const [starting, setStarting] = useState(false)
  const [problem, setProblem] = useState<string | null>(null)
  const [letter, setLetter] = useState<string | null>(null)
  const [lowest, setLowest] = useState(400)
  // Skip asks for focus on Start; it is given once the card is no longer hidden by the animation.
  const focusAfterSkip = useRef(false)
  const first = useRef<Promise<Home> | null>(null)
  const startRef = useRef<HTMLButtonElement>(null)
  const cardBox = useRef<HTMLDivElement>(null)
  const picture = useRef<HTMLDivElement>(null)

  // One load per page load, also under React's strict mode.
  useEffect(() => {
    let active = true
    first.current ??= loadHome()
    void first.current.then((next) => {
      if (!active) return
      setHome(next)
      // The opening animation plays only when this device has no account.
      if (next.kind === 'ready' && !next.today.signedIn) setPlaying(true)
    })
    return () => {
      active = false
    }
  }, [])

  const signedIn = home.kind === 'ready' && home.today.signedIn

  useEffect(() => {
    if (!playing && focusAfterSkip.current) {
      focusAfterSkip.current = false
      startRef.current?.focus()
    }
  }, [playing])

  // A failsafe: the opening animation always ends, even if a browser never fires its end.
  useEffect(() => {
    if (!playing) return undefined
    const timer = setTimeout(() => {
      setPlaying(false)
    }, 6000)
    return () => {
      clearTimeout(timer)
    }
  }, [playing])

  // The account button's letter, once, after the road is drawn, only for a learner.
  useEffect(() => {
    if (!signedIn) return undefined
    let active = true
    void callApi('/api/me', 'GET').then((answer) => {
      if (!active) return
      const kind = accountKindOf(answer)
      if (kind === 'other' || !answer || !isRecord(answer.body)) return
      const email = typeof answer.body.email === 'string' ? answer.body.email : undefined
      setLetter(accountLetter(kind, email))
    })
    return () => {
      active = false
    }
  }, [signedIn])

  // The lowest height a sign may stand at: above the card, in scene units.
  const measure = useCallback(() => {
    // The scene box inside it, by its layout width (the opening animation scales it).
    const box = picture.current?.firstElementChild
    if (!(box instanceof HTMLElement)) return
    const cardHeight = cardBox.current?.offsetHeight ?? CARD_ESTIMATE
    const unit = box.offsetWidth / 280
    if (unit <= 0) return
    // The box starts above the screen's top (offsetTop is negative).
    const room = window.innerHeight - cardHeight - 24 - box.offsetTop
    setLowest(Math.max(260, room / unit))
  }, [])

  useLayoutEffect(() => {
    if (home.kind !== 'ready') return undefined
    measure()
    window.addEventListener('resize', measure)
    const observer = typeof ResizeObserver === 'undefined' ? null : new ResizeObserver(measure)
    if (cardBox.current) observer?.observe(cardBox.current)
    return () => {
      window.removeEventListener('resize', measure)
      observer?.disconnect()
    }
  }, [home, measure])

  async function start() {
    setStarting(true)
    setProblem(null)
    const answer = await callApi('/api/guest', 'POST')
    if (answer && (answer.status === 200 || answer.status === 201)) {
      window.location.assign(PATHS.session)
      return
    }
    setStarting(false)
    setProblem(NOT_STARTED)
  }

  function skip() {
    focusAfterSkip.current = true
    setPlaying(false)
  }

  if (home.kind === 'loading') return <LoadingMark label={LOADING} />
  if (home.kind === 'offline') return <OfflineScreen where="road" />

  const view = homeView(home.road.stops, home.today, noticeFrom(window.location.search))
  const sampleLine = playing ? view.firstStop?.sampleLine : undefined

  return (
    <main
      className={styles.screen}
      data-land={view.evening ? 'evening' : undefined}
      data-intro={playing ? 'on' : undefined}
    >
      <h1 className={styles.hidden}>Your road to A1</h1>
      {playing && (
        <button type="button" className={styles.skip} onClick={skip}>
          Skip
        </button>
      )}
      <div className={styles.world}>
        <div className={styles.pictureBox} ref={picture}>
          <RoadPicture
            signs={view.signs}
            markerAt={view.markerAt}
            travelledTo={view.travelledTo}
            lowest={lowest}
            evening={view.evening}
            intro={playing}
            sampleLine={sampleLine}
          />
        </div>
      </div>
      <div className={styles.top}>
        <RoadTop pieces={view.pieces} letter={signedIn ? letter : null} />
      </div>
      <div
        className={styles.card}
        ref={cardBox}
        onAnimationEnd={(event) => {
          // The card is the last thing the opening animation brings in.
          if (event.target === event.currentTarget) setPlaying(false)
        }}
      >
        <RoadCard
          view={view.card}
          starting={starting}
          problem={problem}
          startRef={startRef}
          onStart={() => void start()}
          onContinue={() => {
            window.location.assign(PATHS.session)
          }}
        />
      </div>
    </main>
  )
}
