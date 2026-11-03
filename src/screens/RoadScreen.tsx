import { useCallback, useEffect, useId, useLayoutEffect, useRef, useState } from 'react'
import { Sheet } from '../components/Sheet.tsx'
import { IslandCard, shownLines, tagText } from '../island/IslandCard.tsx'
import { loadIsland, saveIslandLine } from '../island/island-api.ts'
import { IslandStep } from '../island/IslandStep.tsx'
import islandStyles from '../island/Island.module.css'
import { islandStop } from '../lib/islands.ts'
import type { IslandAnswer } from '../lib/session-types.ts'
import { PATHS } from '../lib/app-paths.ts'
import { accountKindOf } from './save-note.ts'
import { noticeFrom } from '../lib/account-notice.ts'
import { SCENE_HEIGHT, SCENE_WIDTH, SUN_BOX } from '../components/landscape-geometry.ts'
import { accountLetter, fitSigns } from '../lib/road-state.ts'
import { callApi, isRecord } from '../lib/api.ts'
import { loadRoad } from '../lib/road-data.ts'
import { offersIntro, readIntro, REASONS, saveIntro, TIMES, type IntroAnswers } from '../lib/intro-answers.ts'
import { FIRST_LINE_AUDIO } from '../lib/intro-first-line.ts'
import type { RoadView } from '../lib/road-types.ts'
import { homeView, todayInfoFrom, type TodayInfo } from '../road/home-view.ts'
import { LoadingMark } from '../road/LoadingMark.tsx'
import { RoadCard } from '../road/RoadCard.tsx'
import { RoadPicture } from '../road/RoadPicture.tsx'
import { namesWrap, PIN_TEXT_PX, rootTextPx } from '../road/sign-pins.ts'
import { RoadTop } from '../road/RoadTop.tsx'
import { REASON_QUESTION, TIME_QUESTION } from './intro-copy.ts'
import { IntroQuestion } from './IntroQuestion.tsx'
import { LOADING, NOT_STARTED } from './road-copy.ts'
import { OfflineScreen } from './OfflineScreen.tsx'
import styles from './RoadScreen.module.css'

// The home screen: the road to the A1 sun (job 19-redesign, statements 10 to
// 20). The opening animation plays each time it opens (owner, 3 November 2026). It replaces the front door. Loading it creates nothing: only pressing
// "Start" sends POST /api/guest. It reads the stops through loadRoad() and what
// today holds from the existing GET /api/today, and, when a learner is signed
// in, the letter for the account button from GET /api/me, once, after the road
// is drawn.
//
// The first-open questions (fast route "intro", 3 November 2026): on a phone
// that has not seen them, "Start" on the day one card opens two questions, one
// per screen, then the road again with the recap card, whose "Start" is the one
// that sends POST /api/guest. The answers stay on the phone
// (src/lib/intro-answers.ts). The opening animation and the day one card are
// unchanged.

/** Where a new visitor is in the first-open questions. "road" is the road as it always was. */
type IntroStage = 'road' | 'reason' | 'time' | 'recap'

type Home = { kind: 'loading' } | { kind: 'offline' } | { kind: 'ready'; road: RoadView; today: TodayInfo }

/** The sign in cookie only exists after "Start"; without an answer the page offers Start, which finds a guest already on this device. */
async function loadHome(): Promise<Home> {
  const [todayAnswer, road] = await Promise.all([callApi('/api/today', 'GET'), loadRoad()])
  if (!road) return { kind: 'offline' }
  const today = todayAnswer?.status === 200 ? todayInfoFrom(todayAnswer.body) : todayInfoFrom(null)
  return { kind: 'ready', road, today }
}

/** The phone asks for reduced motion. Old browsers without matchMedia count as "no". */
function reducedMotion(): boolean {
  try {
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches
  } catch {
    return false
  }
}

/** The card's room at the bottom, in px, until it is measured. */
const CARD_ESTIMATE = 230

const MOST_SIGNS = 5

export function RoadScreen() {
  const [home, setHome] = useState<Home>({ kind: 'loading' })
  const [playing, setPlaying] = useState(false)
  const [starting, setStarting] = useState(false)
  const [problem, setProblem] = useState<string | null>(null)
  const [letter, setLetter] = useState<string | null>(null)
  const [stage, setStage] = useState<IntroStage>('road')
  const [answers, setAnswers] = useState<IntroAnswers>({ seen: false })
  const recapHeading = useRef<HTMLHeadingElement>(null)
  const [lowest, setLowest] = useState(400)
  // How many signs show. Five when there is room; fewer when the room above the card is short.
  const [signCount, setSignCount] = useState(MOST_SIGNS)
  // The least height between two signs' feet, in scene units, from the tallest board (large text makes boards tall).
  const [signGap, setSignGap] = useState(0)
  // Counts the times the room was measured, so the signs are checked again after every one.
  const [measured, setMeasured] = useState(0)
  // Sideways nudges (px) by stop number for boards that would run past an edge.
  const [shifts, setShifts] = useState<Record<number, number>>({})
  // Number pins in place of the drawn signs when the text is too large for them (the owner's choice of
  // 2 November): text at 200 percent or more, a name that would wrap, or signs that still cover the sun or
  // a fell label when only two are left.
  const [pins, setPins] = useState(false)
  // Skip asks for focus on Start; it is given once the card is no longer hidden by the animation.
  const focusAfterSkip = useRef(false)
  const first = useRef<Promise<Home> | null>(null)
  const startRef = useRef<HTMLButtonElement>(null)
  const cardBox = useRef<HTMLDivElement>(null)
  const picture = useRef<HTMLDivElement>(null)
  const topBox = useRef<HTMLDivElement>(null)
  const textProbe = useRef<HTMLSpanElement>(null)
  // Language islands: the learner's island, the card's sheet and the line being changed.
  const [island, setIsland] = useState<IslandAnswer | null>(null)
  const [islandOpen, setIslandOpen] = useState(false)
  const [editing, setEditing] = useState<number | null>(null)
  const islandTag = useRef<HTMLButtonElement>(null)
  const islandTitle = useId()

  // One load per page load, also under React's strict mode.
  useEffect(() => {
    let active = true
    first.current ??= loadHome()
    void first.current.then((next) => {
      if (!active) return
      setHome(next)
      // The opening animation plays every time the road opens, for everyone (owner, 3 November 2026),
      // and ends on the learner's own stop. With reduced motion on there is none: the end state at once.
      if (next.kind === 'ready' && !reducedMotion()) setPlaying(true)
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

  // The learner's island, once, after the road is drawn, only for a learner (language islands).
  useEffect(() => {
    if (!signedIn) return undefined
    let active = true
    void loadIsland().then((answer) => {
      if (active) setIsland(answer)
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
    const unit = box.offsetWidth / SCENE_WIDTH
    if (unit <= 0) return
    // The box starts above the screen's top (offsetTop is negative).
    const room = window.innerHeight - cardHeight - 24 - box.offsetTop
    setLowest(Math.max(260, room / unit))
    // The room changed (a turn, a text size, a taller card): try all the signs again.
    setSignCount(MOST_SIGNS)
    setShifts({})
    setPins(false)
    setMeasured((count) => count + 1)
  }, [])

  const onQuestions = stage === 'reason' || stage === 'time'

  useLayoutEffect(() => {
    if (home.kind !== 'ready' || playing || onQuestions) return undefined
    // Measured once the opening is over, when the card and the signs stand where they end up.
    measure()
    window.addEventListener('resize', measure)
    const observer = typeof ResizeObserver === 'undefined' ? null : new ResizeObserver(measure)
    if (cardBox.current) observer?.observe(cardBox.current)
    // A box of 1rem: it changes size when the learner's text size does, which the capped card may not.
    if (textProbe.current) observer?.observe(textProbe.current)
    return () => {
      window.removeEventListener('resize', measure)
      observer?.disconnect()
    }
  }, [home, playing, measure, onQuestions])

  // Fewer signs while any two boards touch each other or the top bar (round 3, design review). The
  // sign of the "you" marker and the next one are always kept. It waits for the opening animation,
  // whose scaling would make the boxes look smaller than they end up.
  useLayoutEffect(() => {
    if (home.kind !== 'ready' || playing || onQuestions) return
    if (!pins && (rootTextPx() >= PIN_TEXT_PX || namesWrap(picture.current))) {
      setPins(true)
      setSignCount(MOST_SIGNS)
      return
    }
    const boards = [...(picture.current?.querySelectorAll('ol > li') ?? [])].map((item) => {
      const board = item.firstElementChild?.querySelector('[aria-hidden="true"]')
      return board?.getBoundingClientRect()
    })
    const bar = topBox.current?.getBoundingClientRect()
    const unit = (picture.current?.firstElementChild as HTMLElement | null)?.offsetWidth ?? 0
    // The tallest board with its pole and a little air, so two signs never touch.
    const tallest = Math.max(0, ...boards.map((box) => box?.height ?? 0))
    const wanted = unit > 0 ? Math.ceil((tallest + 22) / (unit / 280)) : 0
    if (wanted > signGap + 1 || wanted < signGap - 12) {
      setSignGap(wanted)
      return
    }
    // A board that runs past the edge of the screen is nudged back inside it, 8 px from the edge.
    const items = [...(picture.current?.querySelectorAll('ol > li') ?? [])]
    const next = { ...shifts }
    const moved: number[] = []
    items.forEach((item, index) => {
      const box = boards[index]
      const number = Number(item.getAttribute('data-stop'))
      if (!box) return
      const room = window.innerWidth - 8
      const delta = box.right > room ? room - box.right : box.left < 8 ? 8 - box.left : 0
      if (Math.abs(delta) >= 1) {
        next[number] = (next[number] ?? 0) + delta
        moved.push(number)
      }
    })
    if (moved.length > 0) {
      setShifts(next)
      return
    }
    const gap = 4
    const touching = (a: DOMRect, b: DOMRect) =>
      a.left < b.right + gap && b.left < a.right + gap && a.top < b.bottom + gap && b.top < a.bottom + gap
    // The sun with its "A1" and the three fell labels are kept clear of every board (round 6).
    const scene = picture.current?.firstElementChild?.getBoundingClientRect()
    const scenery: DOMRect[] = [
      ...[...(picture.current?.querySelectorAll('ul > li') ?? [])].map((label) =>
        label.getBoundingClientRect(),
      ),
      ...(scene
        ? [
            new DOMRect(
              scene.left + (SUN_BOX.left / SCENE_WIDTH) * scene.width,
              scene.top + (SUN_BOX.top / SCENE_HEIGHT) * scene.height,
              ((SUN_BOX.right - SUN_BOX.left) / SCENE_WIDTH) * scene.width,
              ((SUN_BOX.bottom - SUN_BOX.top) / SCENE_HEIGHT) * scene.height,
            ),
          ]
        : []),
    ]
    const crowded = boards.some(
      (box, index) =>
        box !== undefined &&
        (box.top < (bar?.bottom ?? 0) + gap ||
          scenery.some((thing) => touching(box, thing)) ||
          boards.slice(index + 1).some((other) => other !== undefined && touching(box, other))),
    )
    if (crowded && signCount > 2) setSignCount(signCount - 1)
    else if (crowded && !pins) {
      setPins(true)
      setSignCount(MOST_SIGNS)
    }
  }, [home, playing, signCount, signGap, lowest, measured, shifts, pins, onQuestions])

  // The recap card's title takes focus when the road comes back with it.
  useEffect(() => {
    if (stage === 'recap') recapHeading.current?.focus({ preventScroll: true })
  }, [stage])

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

  /** Day one's Start: a new visitor answers the two questions first; everyone else starts at once. */
  function begin(ended: boolean) {
    if (offersIntro('day-one', ended, readIntro())) {
      setProblem(null)
      setStage('reason')
      return
    }
    void start()
  }

  /** The questions are over: the phone keeps the answers (if it can) and shows the recap card. */
  function finishQuestions(next: IntroAnswers) {
    const done = { ...next, seen: true }
    setAnswers(done)
    saveIntro(done)
    setStage('recap')
  }

  function skip() {
    focusAfterSkip.current = true
    setPlaying(false)
  }

  // Changing or adding an island line from the island card (language islands): the island step,
  // then the road again with the card open.
  const editStop = editing === null ? undefined : islandStop(editing)
  if (editStop) {
    const initial = island?.lines.find((line) => line.stop === editStop.stop)
    return (
      <IslandStep
        stop={editStop}
        initial={initial}
        frame={{ step: 'Use it', steps: ['Use it'] }}
        leaveHref={PATHS.home}
        onSave={async (entry) => {
          const result = await saveIslandLine(entry)
          if (result === 'signed_out') {
            window.location.replace(PATHS.home)
            return false
          }
          if (result !== 'saved') return false
          setIsland(await loadIsland())
          setEditing(null)
          setIslandOpen(true)
          return true
        }}
      />
    )
  }

  if (home.kind === 'loading') return <LoadingMark label={LOADING} />
  if (home.kind === 'offline') return <OfflineScreen where="road" />

  if (stage === 'reason') {
    return (
      <IntroQuestion
        question={REASON_QUESTION}
        options={REASONS}
        backLabel="Back to the road"
        onBack={() => {
          setStage('road')
        }}
        onAnswer={(value) => {
          setAnswers({ seen: false, reason: REASONS.find((option) => option.value === value)?.value })
          setStage('time')
        }}
        onSkip={() => {
          setAnswers({ seen: false })
          setStage('time')
        }}
      />
    )
  }
  if (stage === 'time') {
    return (
      <IntroQuestion
        question={TIME_QUESTION}
        options={TIMES}
        backLabel="Back to the first question"
        onBack={() => {
          setStage('reason')
        }}
        onAnswer={(value) => {
          finishQuestions({ ...answers, time: TIMES.find((option) => option.value === value)?.value })
        }}
        onSkip={() => {
          finishQuestions({ ...answers, time: undefined })
        }}
      />
    )
  }

  const homeNow = homeView(home.road.stops, home.today, noticeFrom(window.location.search))
  const firstStop = home.road.stops.at(0)
  const view =
    stage === 'recap' && homeNow.card.kind === 'day-one' && firstStop
      ? { ...homeNow, card: { kind: 'recap' as const, stop: firstStop, audio: FIRST_LINE_AUDIO } }
      : homeNow
  const ended = home.today.ended
  // The speech bubble is stop 1's line, so it shows only when the animation ends on stop 1 (day one).
  const sampleLine = playing && view.card.kind === 'day-one' ? view.firstStop?.sampleLine : undefined
  const shown = fitSigns(view.signs, view.markerAt, signCount)
  // The "Your island" tag: for a learner with a line, or a finished stop whose line waits.
  const showTag = signedIn && !playing && stage === 'road'

  return (
    <main
      className={styles.screen}
      data-land={view.evening ? 'evening' : undefined}
      data-intro={playing ? 'on' : undefined}
    >
      <h1 className={styles.hidden}>Your road to A1</h1>
      <span className={styles.probe} ref={textProbe} aria-hidden="true" />
      {playing && (
        <button type="button" className={styles.skip} onClick={skip}>
          Skip
        </button>
      )}
      <div className={styles.world}>
        <div className={styles.pictureBox} ref={picture}>
          <RoadPicture
            signs={shown.signs}
            markerAt={shown.markerAt}
            travelledTo={view.travelledTo}
            lowest={lowest}
            signGap={signGap}
            shifts={shifts}
            pins={pins}
            evening={view.evening}
            intro={playing}
            sampleLine={sampleLine}
          />
        </div>
      </div>
      <div className={styles.top} ref={topBox}>
        <RoadTop pieces={view.pieces} letter={signedIn ? letter : null} />
        {showTag && island && (island.lines.length > 0 || island.open.length > 0) && (
          <div className={islandStyles.tagRow}>
            <button
              ref={islandTag}
              type="button"
              className={islandStyles.tag}
              aria-haspopup="dialog"
              onClick={() => {
                setIslandOpen(true)
              }}
            >
              {tagText(shownLines(island.lines).length)}
            </button>
          </div>
        )}
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
          headingRef={recapHeading}
          onStart={() => {
            if (view.card.kind === 'day-one') begin(ended)
            else void start()
          }}
          onContinue={() => {
            window.location.assign(PATHS.session)
          }}
        />
      </div>
      <Sheet
        open={islandOpen && island !== null}
        labelledBy={islandTitle}
        returnFocus={islandTag}
        onClose={() => {
          setIslandOpen(false)
        }}
      >
        {island && (
          <IslandCard
            titleId={islandTitle}
            lines={island.lines}
            open={island.open}
            onChange={(stop) => {
              setIslandOpen(false)
              setEditing(stop)
            }}
          />
        )}
      </Sheet>
    </main>
  )
}
