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
import { callApi, isRecord, type ApiAnswer } from '../lib/api.ts'
import { loadHumanCheck, runHumanCheck } from '../lib/human-check.ts'
import { loadRoad } from '../lib/road-data.ts'
import { clearOldIntroKeys, introDue, JOURNEY_AUDIO, markVisit, watchVisit } from '../lib/aleksi-intro.ts'
import { BUBBLE_AFTER, IntroVoice, JOURNEY_AFTER, START_AFTER } from '../lib/intro-voice.ts'
import type { RoadView } from '../lib/road-types.ts'
import { homeView, todayInfoFrom, type TodayInfo } from '../road/home-view.ts'
import { LoadingMark } from '../road/LoadingMark.tsx'
import { PracticeSheet, type PracticeList } from '../road/PracticeSheet.tsx'
import { practiceQuery, type PracticeListAnswer } from '../lib/practice-types.ts'
import { RoadPicture } from '../road/RoadPicture.tsx'
import { namesWrap, PIN_TEXT_PX, rootTextPx, signBox, signParts } from '../road/sign-pins.ts'
import { RoadStart } from '../road/RoadStart.tsx'
import { RoadTop } from '../road/RoadTop.tsx'
import { startNote, startPlan, type StartGo } from '../road/start-plan.ts'
import { StopScreen } from '../road/StopScreen.tsx'
import { AleksiIntro } from './AleksiIntro.tsx'
import { CHECK_FAILED, CHECK_UNAVAILABLE, LOADING, NOT_STARTED } from './road-copy.ts'
import { OfflineScreen } from './OfflineScreen.tsx'
import styles from './RoadScreen.module.css'

// The home screen: the road to the A1 sun (job 19-redesign, statements 10 to
// 20). The opening animation plays each time it opens (owner, 3 November 2026). It replaces the front door. Loading it creates nothing: only pressing
// "Start" sends POST /api/guest. It reads the stops through loadRoad() and what
// today holds from the existing GET /api/today, and, when a learner is signed
// in, the letter for the account button from GET /api/me, once, after the road
// is drawn.
//
// Meeting Aleksi (fast route aleksi-intro, 4 November 2026): at the start of a visit, a learner who meets
// him (everyone except a signed in email account with a finished stop) first sees Aleksi's intro. Coming
// back to the road in the same visit, from a lesson for example, opens the road straight away (fast route
// intro-visit, owner, 5 November 2026). The day one card's Start then goes straight to the first lesson;
// the two first-open questions and the recap card of fast route "intro" are gone.
//
// The new intro (fast route intro-logo, version E with its quick timing, owner approved 5 November 2026)
// replaces the "Nice to meet you" screen. It plays on its own with no tap (src/screens/AleksiIntro.tsx): the
// logo zooms away, then the lesson card with his greeting, spoken (and said) then written. As the card
// leaves, this page's road comes in under it with its opening animation; while the road draws, his bubble
// shows his journey line (0.3 s in), he says it (0.45 s in), and Start comes in (2.55 s in). Both clips play
// on one audio element (src/lib/intro-voice.ts), so they never overlap; a phone that blocks sound before a
// tap starts his voice on the first tap. Skip, at any moment, or reduced motion, goes straight to the end
// state: the road, his bubble with its play button, and Start, with no animation and no sound. The visit is
// marked (one time stamp kept for this tab by src/lib/aleksi-intro.ts) when the intro ends, on Skip, or on
// Start.
//
// The clean road (fast route road-stops, owner approved 5 November 2026): the bottom card is gone for
// everyone. The road shows its signs, each with its stop's picture, and one Start button. On the visit
// Aleksi has just introduced himself, his photo and one white bubble sit above Start once the opening
// animation is over. Start opens Aleksi's stop screen (src/road/StopScreen.tsx) before a stop the learner
// has not begun, and goes straight to the lesson part way through one (src/road/start-plan.ts). The stop
// screen is part of this page: it adds one entry to the browser's history, so the phone's back gesture
// returns to the road, and it keeps nothing.

type Home = { kind: 'loading' } | { kind: 'offline' } | { kind: 'ready'; road: RoadView; today: TodayInfo }

/**
 * Where Aleksi's intro is on this page: none (not due), the intro screen (the logo, the lesson card), on the
 * road (the card leaving over it, his bubble and journey line while the road draws), or over (the end state).
 */
type IntroStage = 'none' | 'card' | 'road' | 'over'

/** The sign in cookie only exists after "Start"; without an answer the page offers Start, which finds a guest already on this device. */
async function loadHome(): Promise<Home> {
  const [todayAnswer, road] = await Promise.all([callApi('/api/today', 'GET'), loadRoad()])
  if (!road) return { kind: 'offline' }
  const today = todayAnswer?.status === 200 ? todayInfoFrom(todayAnswer.body) : todayInfoFrom(null)
  return { kind: 'ready', road, today }
}

/** The public Turnstile site key when POST /api/guest asks for the bot check first (job turnstile). */
function checkSiteKeyOf(answer: ApiAnswer | null): string | null {
  if (answer?.status !== 403 || !isRecord(answer.body)) return null
  const { error, siteKey } = answer.body
  return (error === 'check_needed' || error === 'check_failed') &&
    typeof siteKey === 'string' &&
    siteKey !== ''
    ? siteKey
    : null
}

/** What to say when Start did not work. */
function startProblemOf(answer: ApiAnswer | null): string {
  if (isRecord(answer?.body)) {
    if (answer.body.error === 'check_failed') return CHECK_FAILED
    if (answer.body.error === 'check_unavailable') return CHECK_UNAVAILABLE
  }
  return NOT_STARTED
}

/** The phone asks for reduced motion. Old browsers without matchMedia count as "no". */
function reducedMotion(): boolean {
  try {
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches
  } catch {
    return false
  }
}

function isPracticeList(body: unknown): body is PracticeListAnswer {
  return isRecord(body) && Array.isArray(body.lessons)
}

/** The learner's finished lessons, for the practice sheet (fast route go-back). */
async function loadPracticeList(): Promise<PracticeList> {
  const answer = await callApi('/api/practice', 'GET')
  return answer?.status === 200 && isPracticeList(answer.body)
    ? { kind: 'ready', lessons: answer.body.lessons }
    : { kind: 'problem' }
}

/** The room of Start at the bottom, in px, until it is measured. */
const CARD_ESTIMATE = 120

/**
 * While Aleksi's bubble shows (fast route intro-logo, owner, 5 November 2026): the lowest point of the road
 * a sign or the "you" marker may stand at is this far above the bubble's real top, in px. The marker reaches
 * 15 px below its point, its pulse ring 13 px more, 12 px stay clear above the bubble, and 4 px are spare for
 * the road's own rounding (measured: without them the clearance was 11 px at 320 x 568).
 */
const BUBBLE_CLEAR = 15 + 13 + 12 + 4

const MOST_SIGNS = 5

export function RoadScreen() {
  const [home, setHome] = useState<Home>({ kind: 'loading' })
  const [playing, setPlaying] = useState(false)
  const [starting, setStarting] = useState(false)
  /** Cloudflare's bot check is asking the learner to act (job turnstile). */
  const [asking, setAsking] = useState(false)
  const checkSlot = useRef<HTMLDivElement>(null)
  const [problem, setProblem] = useState<string | null>(null)
  const [letter, setLetter] = useState<string | null>(null)
  /** Where Aleksi's intro is (fast route intro-logo). */
  const [introStage, setIntroStage] = useState<IntroStage>('none')
  const meeting = introStage === 'card'
  // The intro's one audio element, for both of Aleksi's clips, so they never overlap.
  const [voice] = useState(() => new IntroVoice())
  // How the intro ended on this page: played to its end (Start then comes in), or skipped (all there at once).
  const [introEnd, setIntroEnd] = useState<'played' | 'skipped' | null>(null)
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
  // In number pin mode the pins show their pictures too, as long as they fit (fast route road-stops).
  const [pinPictures, setPinPictures] = useState(true)
  // Aleksi's stop screen is open in place of the road (fast route road-stops).
  const [stopOpen, setStopOpen] = useState(false)
  // Aleksi introduced himself on this page: the road shows his bubble until Start.
  const justMet = introStage === 'road' || introStage === 'over'
  // On the road during the intro, his bubble is up (0.3 s after the road came in).
  const [bubbleUp, setBubbleUp] = useState(false)
  // Whether the road has a Start, so his bubble has its place (it has none when nothing is ready).
  const bubbleRoom =
    introStage === 'road' &&
    home.kind === 'ready' &&
    startPlan(homeView(home.road.stops, home.today, noticeFrom(window.location.search)).card).kind !== 'none'
  const [bubbleGone, setBubbleGone] = useState(false)
  // The stop screen's entry in the browser's history, so Back and the phone's back gesture both close it.
  const stopEntry = useRef(false)
  // Skip asks for focus on Start; it is given once Start is no longer hidden by the animation. Coming back
  // from the stop screen asks the same.
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
  // Practice replays (fast route go-back): the done stop whose lessons the sheet shows, and the list.
  const [practiceStop, setPracticeStop] = useState<number | null>(null)
  const [practiceList, setPracticeList] = useState<PracticeList>({ kind: 'loading' })
  const practiceOpener = useRef<HTMLElement | null>(null)
  const practiceTitleId = useId()

  // One load per page load, also under React's strict mode.
  useEffect(() => {
    let active = true
    // The keys of earlier versions leave the phone: the old first-open answers and the old "met" flag.
    clearOldIntroKeys()
    first.current ??= loadHome()
    void first.current.then((next) => {
      if (!active) return
      setHome(next)
      if (next.kind !== 'ready') return
      // Aleksi's intro comes first for everyone except a signed in email account that has finished a whole
      // stop (owner, 4 November 2026), and only at the start of a visit (owner, 5 November 2026). With
      // reduced motion it is its end state at once, and the visit is marked (fast route intro-logo).
      if (introDue(next.today)) {
        if (reducedMotion()) {
          markVisit()
          setIntroStage('over')
        } else setIntroStage('card')
        return
      }
      // The road is open: the visit starts here, or goes on.
      markVisit()
      // The opening animation plays every time the road opens, for everyone (owner, 3 November 2026),
      // and ends on the learner's own stop. With reduced motion on there is none: the end state at once.
      if (!reducedMotion()) setPlaying(true)
    })
    return () => {
      active = false
    }
  }, [])

  const signedIn = home.kind === 'ready' && home.today.signedIn

  // The intro's voice stops when the page goes.
  useEffect(
    () => () => {
      voice.close()
    },
    [voice],
  )

  /**
   * The intro is over: its end state, and the visit is marked. Skip stops the voice and the road's opening
   * animation at once. At its natural end the road goes on settling, and his last words are not cut.
   */
  const finishIntro = useCallback(
    (skipped: boolean) => {
      if (skipped) {
        voice.close()
        focusAfterSkip.current = true
        setPlaying(false)
      }
      markVisit()
      setIntroEnd(skipped ? 'skipped' : 'played')
      setIntroStage('over')
    },
    [voice],
  )

  // The road has come in under the leaving card: while it draws, his bubble shows, he says his journey line,
  // then Start comes in. When the road has no Start (nothing ready) there is no bubble and no line.
  useEffect(() => {
    if (introStage !== 'road') return undefined
    const timers = [
      window.setTimeout(() => {
        setBubbleUp(true)
      }, BUBBLE_AFTER),
      window.setTimeout(() => {
        if (bubbleRoom) void voice.say(JOURNEY_AUDIO)
      }, JOURNEY_AFTER),
      window.setTimeout(() => {
        finishIntro(false)
      }, START_AFTER),
    ]
    return () => {
      for (const timer of timers) window.clearTimeout(timer)
    }
  }, [introStage, bubbleRoom, voice, finishIntro])

  // While the app is in use (taps, keys, hiding or leaving the page) the visit goes on (fast route intro-visit).
  useEffect(() => watchVisit(window, document), [])

  useEffect(() => {
    // Also after the intro's Skip, once the road and Start are in the page (introStage).
    if (!playing && !stopOpen && introStage !== 'card' && focusAfterSkip.current) {
      focusAfterSkip.current = false
      startRef.current?.focus()
    }
  }, [playing, stopOpen, introStage])

  // The phone's back gesture (or the browser's Back) on the stop screen returns to the road.
  useEffect(() => {
    const onPop = () => {
      if (!stopEntry.current) return
      stopEntry.current = false
      focusAfterSkip.current = true
      setProblem(null)
      setStopOpen(false)
    }
    window.addEventListener('popstate', onPop)
    return () => {
      window.removeEventListener('popstate', onPop)
    }
  }, [])

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
    // While Aleksi's bubble is in the page, the road is laid out above its real top (it keeps its room while
    // hidden, and the bottom area does not move during the intro), so it never covers the marker or a sign.
    const bubble = cardBox.current?.querySelector('[data-testid="road-bubble"]')
    const above =
      bubble instanceof HTMLElement
        ? bubble.getBoundingClientRect().top - BUBBLE_CLEAR
        : window.innerHeight - cardHeight - 24
    // The box starts above the screen's top (offsetTop is negative).
    const room = above - box.offsetTop
    setLowest(Math.max(260, room / unit))
    // The room changed (a turn, a text size, a taller card): try all the signs again.
    setSignCount(MOST_SIGNS)
    setShifts({})
    setPins(false)
    setPinPictures(true)
    setMeasured((count) => count + 1)
  }, [])

  // On the intro's road the bottom area does not move while the road draws (fast route intro-logo), so the
  // road is measured as it comes in: the signs and the marker stand clear of the bubble from the first frame.
  const measureNow = !playing || introStage === 'road'
  useLayoutEffect(() => {
    if (home.kind !== 'ready' || !measureNow || meeting || stopOpen) return undefined
    // Measured once the opening is over, when Start and the signs stand where they end up.
    measure()
    window.addEventListener('resize', measure)
    const observer = typeof ResizeObserver === 'undefined' ? null : new ResizeObserver(measure)
    if (cardBox.current) observer?.observe(cardBox.current)
    // A box of 1rem: it changes size when the learner's text size does, which the bottom area may not.
    if (textProbe.current) observer?.observe(textProbe.current)
    return () => {
      window.removeEventListener('resize', measure)
      observer?.disconnect()
    }
  }, [home, measureNow, measure, meeting, stopOpen])

  // Fewer signs while any two boards touch each other or the top bar (round 3, design review). The
  // sign of the "you" marker and the next one are always kept. It waits for the opening animation,
  // whose scaling would make the boxes look smaller than they end up.
  // A sign's box is its board with its picture above it (fast route road-stops).
  useLayoutEffect(() => {
    if (home.kind !== 'ready' || playing || meeting || stopOpen) return
    if (!pins && (rootTextPx() >= PIN_TEXT_PX || namesWrap(picture.current))) {
      setPins(true)
      setSignCount(MOST_SIGNS)
      return
    }
    const boards = [...(picture.current?.querySelectorAll('ol > li') ?? [])].map(signBox)
    const bar = topBox.current?.getBoundingClientRect()
    const unit = (picture.current?.firstElementChild as HTMLElement | null)?.offsetWidth ?? 0
    // The tallest board with its pole and a little air, so two signs never touch. Neighbouring signs stand
    // on opposite sides of the road, so a picture above a board needs no extra height here: the check
    // below still keeps every picture clear of every other sign.
    const tallest = Math.max(
      0,
      ...[...(picture.current?.querySelectorAll('[data-sign-board]') ?? [])].map(
        (board) => board.getBoundingClientRect().height,
      ),
    )
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
    // The "you" marker with its halo is kept clear of every picture but its own sign's (fast route
    // road-stops), so no picture stands behind it. Boards are left as they were before pictures: a long name
    // may reach across the road near the marker.
    const you = picture.current?.querySelector('[data-testid="you-marker"]')?.getBoundingClientRect()
    const halo = you ? new DOMRect(you.left - 13, you.top - 13, you.width + 26, you.height + 26) : undefined
    const ownSign = items.map((item) => item.hasAttribute('data-you'))
    const signPicture = items.map((item) =>
      item.querySelector('[data-sign-picture]')?.getBoundingClientRect(),
    )
    const overlaps = (a: DOMRect, b: DOMRect) =>
      a.left < b.right && b.left < a.right && a.top < b.bottom && b.top < a.bottom
    // A board and its picture are checked as two boxes: a narrow picture above a wide board leaves the
    // board's top corners free, so the picture of one sign may stand beside the board of the next.
    const parts = items.map(signParts)
    const meets = (a: readonly DOMRect[], b: readonly DOMRect[]) =>
      a.some((one) => b.some((two) => touching(one, two)))
    const crowded = boards.some(
      (box, index) =>
        box !== undefined &&
        (box.top < (bar?.bottom ?? 0) + gap ||
          meets(parts[index] ?? [], scenery) ||
          (halo !== undefined &&
            !ownSign[index] &&
            signPicture[index] !== undefined &&
            overlaps(signPicture[index], halo)) ||
          parts.slice(index + 1).some((other) => meets(parts[index] ?? [], other))),
    )
    if (!crowded) return
    // Number pins show their pictures only when they fit: crowded pins first lose the pictures, then signs.
    if (pins && pinPictures) {
      setPinPictures(false)
      setSignCount(MOST_SIGNS)
    } else if (signCount > 2) setSignCount(signCount - 1)
    else if (!pins) {
      setPins(true)
      setSignCount(MOST_SIGNS)
    }
  }, [
    home,
    playing,
    signCount,
    signGap,
    lowest,
    measured,
    shifts,
    pins,
    pinPictures,
    meeting,
    island,
    stopOpen,
  ])

  // "Start": makes or finds the guest account, then opens the session. A new
  // guest first passes Cloudflare Turnstile (job turnstile): the Worker answers
  // check_needed with the site key, the check runs in the card, and Start is
  // sent again with the token. A signed in learner goes straight through, and
  // Turnstile's script is never loaded for them.
  async function start() {
    setStarting(true)
    setProblem(null)
    // A new guest will need the check, so its script starts loading now, beside the first request.
    if (!signedIn) void loadHumanCheck()
    let answer = await callApi('/api/guest', 'POST')
    const siteKey = checkSiteKeyOf(answer)
    if (siteKey) {
      const slot = checkSlot.current
      const result = slot
        ? await runHumanCheck(slot, siteKey, setAsking)
        : ({ problem: 'unavailable' } as const)
      if ('problem' in result) {
        setStarting(false)
        setProblem(result.problem === 'failed' ? CHECK_FAILED : CHECK_UNAVAILABLE)
        return
      }
      answer = await callApi('/api/guest', 'POST', { turnstileToken: result.token })
    }
    if (answer && (answer.status === 200 || answer.status === 201)) {
      window.location.assign(PATHS.session)
      return
    }
    setStarting(false)
    setProblem(startProblemOf(answer))
  }

  /** The intro's card is leaving: the road opens under it with its animation (a phone that turned motion off meanwhile gets the end state). */
  function roadIn() {
    if (reducedMotion()) {
      finishIntro(false)
      return
    }
    setIntroStage('road')
    setPlaying(true)
  }

  /** Where Start or Continue goes: makes or finds the account first, or straight to the open session. */
  function go(goal: StartGo) {
    if (goal === 'session') window.location.assign(PATHS.session)
    else void start()
  }

  /** Opens Aleksi's stop screen, with its own entry in the browser's history. */
  function openStop() {
    setProblem(null)
    try {
      window.history.pushState(window.history.state, '')
      stopEntry.current = true
    } catch {
      stopEntry.current = false
    }
    setStopOpen(true)
  }

  /** The stop screen's back button: the same as the phone's back gesture. */
  function closeStop() {
    if (stopEntry.current) {
      window.history.back()
      return
    }
    focusAfterSkip.current = true
    setProblem(null)
    setStopOpen(false)
  }

  /** Opens the practice sheet for a done stop, loading the finished lessons the first time. */
  function openPractice(stop: number) {
    // Safari does not focus a tapped button: focus then goes back to Start, if shown.
    const active = document.activeElement
    practiceOpener.current =
      active instanceof HTMLElement && active !== document.body ? active : startRef.current
    setPracticeStop(stop)
    if (practiceList.kind !== 'ready') {
      setPracticeList({ kind: 'loading' })
      void loadPracticeList().then(setPracticeList)
    }
  }

  function skip() {
    // During the intro, Skip goes to its end state and marks the visit.
    if (introStage === 'road') {
      finishIntro(true)
      return
    }
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

  // The intro screen. It stays in the page, over the road, while its card leaves; the same element in both
  // returns below (its key), so it plays on without starting again.
  const intro = (
    <AleksiIntro
      key="intro"
      voice={voice}
      onSkip={() => {
        finishIntro(true)
      }}
      onRoad={roadIn}
    />
  )
  if (meeting)
    return (
      <>
        {null}
        {intro}
      </>
    )

  const view = homeView(home.road.stops, home.today, noticeFrom(window.location.search))
  const plan = startPlan(view.card)

  if (stopOpen && plan.kind === 'stop-screen') {
    return (
      <StopScreen
        stop={plan.stop}
        visitor={!signedIn}
        onBack={closeStop}
        onContinue={() => {
          go(plan.go)
        }}
        starting={starting}
        problem={problem}
        checkRef={checkSlot}
        asking={asking}
      />
    )
  }

  // The speech bubble is stop 1's line, so it shows only when the animation ends on stop 1 (day one).
  const sampleLine = playing && view.card.kind === 'day-one' ? view.firstStop?.sampleLine : undefined
  const shown = fitSigns(view.signs, view.markerAt, signCount)
  const shownPractice =
    practiceStop === null ? undefined : home.road.stops.find((stop) => stop.number === practiceStop)
  // The "Your island" tag: for a learner with a line, or a finished stop whose line waits.
  const showTag = signedIn && !playing

  return (
    <>
      <main
        className={styles.screen}
        data-land={view.evening ? 'evening' : undefined}
        data-intro={playing ? 'on' : undefined}
        data-met={justMet ? 'yes' : undefined}
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
              onPick={signedIn && !playing ? openPractice : undefined}
              pictures={!pins || pinPictures}
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
          data-testid="road-start"
          data-bubble={justMet && !bubbleGone ? 'yes' : undefined}
          onAnimationEnd={(event) => {
            // Start is the last thing the opening animation brings in.
            if (event.target === event.currentTarget) setPlaying(false)
          }}
        >
          <RoadStart
            showStart={plan.kind !== 'none'}
            note={startNote(view.card)}
            bubble={justMet && !bubbleGone && plan.kind !== 'none'}
            bubbleShown={!playing || bubbleUp}
            bubblePlayable={introStage === 'over'}
            bubbleEnters={introStage === 'road'}
            startWaits={introStage === 'road'}
            startEnters={introStage === 'over' && introEnd === 'played'}
            onStart={() => {
              setBubbleGone(true)
              // Start marks the visit too (fast route intro-logo).
              if (justMet) markVisit()
              if (plan.kind === 'stop-screen') openStop()
              else if (plan.kind === 'straight') go(plan.go)
            }}
            starting={starting}
            problem={problem}
            startRef={startRef}
            checkRef={checkSlot}
            asking={asking}
          />
        </div>
        <Sheet
          open={shownPractice !== undefined}
          labelledBy={practiceTitleId}
          returnFocus={practiceOpener}
          onClose={() => {
            setPracticeStop(null)
          }}
        >
          {shownPractice && (
            <PracticeSheet
              titleId={practiceTitleId}
              stop={shownPractice}
              list={practiceList}
              onPick={(lesson) => {
                window.location.assign(`${PATHS.session}${practiceQuery(lesson.dialogueId)}`)
              }}
              onRetry={() => {
                setPracticeList({ kind: 'loading' })
                void loadPracticeList().then(setPracticeList)
              }}
              onClose={() => {
                setPracticeStop(null)
              }}
            />
          )}
        </Sheet>
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
      {introStage === 'road' ? intro : null}
    </>
  )
}
