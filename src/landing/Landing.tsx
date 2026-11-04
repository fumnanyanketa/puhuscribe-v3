import { useSyncExternalStore, type ReactNode } from 'react'
import { PATHS } from '../lib/app-paths.ts'
import { HeroRoad } from './HeroRoad.tsx'
import styles from './Landing.module.css'
import { useReveal } from './use-reveal.ts'

// The public landing page at "/" (job 17-landing-page). The words are the owner's approved copy
// (factory/jobs/17-landing-page/approved-copy.md) and the look is the owner's approved design
// (approved-design.html), rebuilt with the app's tokens. The page is drawn into the HTML when the
// app is built (scripts/landing/prerender.ts), so it reads without script. It sets no cookie,
// stores nothing, calls no /api route and loads nothing from another address. Every button opens
// the app at /learn.

const START = 'Start your journey now'

function Arrow() {
  return (
    <span className={styles.arrow} aria-hidden="true">
      <svg viewBox="0 0 16 16" focusable="false">
        <path d="M3 8h9M8.5 4.5 12 8l-3.5 3.5" />
      </svg>
    </span>
  )
}

function StartLink() {
  return (
    <a className={styles.button} href={PATHS.home}>
      {START}
      <Arrow />
    </a>
  )
}

/** A word whose spoken and written forms differ, marked as the app marks it. */
function Changed({ children }: { children: ReactNode }) {
  return <span className={styles.changed}>{children}</span>
}

function Fi({ children }: { children: ReactNode }) {
  return <span lang="fi">{children}</span>
}

/** The hero phone shows the road only once the page runs, so the page's HTML holds the empty frame. */
const noChange = () => () => undefined

function useMounted(): boolean {
  // False in the built HTML and while React attaches to it, true once the page runs.
  return useSyncExternalStore(
    noChange,
    () => true,
    () => false,
  )
}

function Hero() {
  const mounted = useMounted()
  return (
    <header className={styles.hero}>
      <div className={`${styles.inner} ${styles.heroInner}`}>
        <div className={styles.heroCopy}>
          <h1 className={styles.title}>You took a Finnish course, but you still feel lost at the café.</h1>
          <p className={styles.lead}>
            That’s because Finns speak <Fi>puhekieli</Fi>, and courses teach <Fi>kirjakieli</Fi>, the written
            form. PuhuScribe is here to help you make sense of both, and takes you along the journey all the
            way to A1.
          </p>
          <StartLink />
          <p className={styles.note}>No need to download any app. Works on iPhone and Android.</p>
        </div>
        <div className={styles.stage}>
          <div className={`${styles.heroCard} ${styles.heroCardLeft}`} aria-hidden="true">
            <img src="/landing/hero-say-it.webp" alt="" width={500} height={766} />
          </div>
          <div className={`${styles.heroCard} ${styles.heroCardRight}`} aria-hidden="true">
            <img src="/landing/hero-otso.webp" alt="" width={500} height={766} />
          </div>
          <div
            className={styles.device}
            role="img"
            aria-label="The PuhuScribe app on a phone: the road to A1 opens with its first stop, Meeting people."
          >
            <div className={styles.deviceScreen}>{mounted && <HeroRoad />}</div>
          </div>
        </div>
      </div>
    </header>
  )
}

function Story() {
  return (
    <section className={`${styles.band} ${styles.story}`} aria-labelledby="story-1">
      <div className={styles.inner}>
        <div className={styles.storyPanel}>
          <div className={styles.storyText}>
            <div data-reveal="">
              <h2 id="story-1" className={styles.h2}>
                You live here, yet the small talk happens without you
              </h2>
              <p className={styles.storyP}>
                You practise a sentence on the way to the shop. The answer comes back fast and sounds nothing
                like what you heard in class, so you switch to English and smile at the attendant, or just nod
                along at the coffee break, like a guest in your own neighbourhood.
              </p>
            </div>
            <div data-reveal="">
              <h2 className={styles.h2}>What you learned still counts</h2>
              <p className={styles.storyP}>
                <Fi>Kirjakieli</Fi> is the base. <Fi>Puhekieli</Fi> is how Finns bend it in everyday speech,
                so “<Fi>Minä olen</Fi>” becomes “<Fi>Mä oon</Fi>”. Once you see the pattern, the Finnish
                around you starts to make sense.
              </p>
            </div>
            <div data-reveal="">
              <h2 className={styles.h2}>One stop at a time, Finland opens up</h2>
              <p className={styles.storyP}>
                First the café and the bus. Later the health centre, your first day at work, and the sauna.
                Each stop adds Finnish you can use in real life.
              </p>
            </div>
          </div>
          <figure
            className={styles.compare}
            aria-label="An example sentence as people say it and as it’s written"
            data-reveal=""
          >
            <div className={styles.compareCard}>
              <span className={styles.compareLabel}>As people say it</span>
              <span className={styles.compareSpoken} lang="fi">
                <Changed>Mä oon</Changed> kotoisin Nigeriasta.
              </span>
            </div>
            <div className={styles.compareCard}>
              <span className={styles.compareLabel}>As it’s written</span>
              <span className={styles.compareWritten} lang="fi">
                <Changed>Minä olen</Changed> kotoisin Nigeriasta.
              </span>
            </div>
            <div className={styles.compareCard}>
              <span className={styles.compareLabel}>Meaning</span>
              <span className={styles.compareMeaning}>I’m from Nigeria.</span>
            </div>
          </figure>
        </div>
      </div>
    </section>
  )
}

interface Feature {
  title: string
  text: ReactNode
  image: string
  alt: string
  height: number
  tone: 'mint' | 'peach'
  piece: ReactNode
}

const FEATURES: Feature[] = [
  {
    title: 'Hear it the way Finns say it',
    text: (
      <>
        Every line comes as people say it and as it’s written, with audio for both. The words that change are
        marked, so you see how “<Fi>Paljonko</Fi>” becomes “<Fi>Paljonks</Fi>”.
      </>
    ),
    image: '/landing/hear-it.webp',
    alt: 'A line in the app in both Finnishes, as people say it and as it’s written, with a play button for each.',
    height: 672,
    tone: 'mint',
    piece: (
      <div className={styles.mini}>
        <div className={styles.miniRow}>
          <span className={`${styles.dot} ${styles.dotSpoken}`} />
          <span className={styles.miniSpoken} lang="fi">
            <Changed>Paljonks</Changed> se maksaa?
          </span>
        </div>
        <div className={styles.miniRow}>
          <span className={`${styles.dot} ${styles.dotWritten}`} />
          <span className={styles.miniWritten} lang="fi">
            <Changed>Paljonko</Changed> se maksaa?
          </span>
        </div>
      </div>
    ),
  },
  {
    title: 'Practise out loud before the real moment',
    text: 'You hear each line and say it straight back, with gentle feedback on how clear you were. By the time you reach the pharmacy counter, the words feel familiar.',
    image: '/landing/say-it.webp',
    alt: 'Saying a line back in the app, with the gentle feedback “Yes, that was clear.”',
    height: 1299,
    tone: 'peach',
    piece: (
      <div className={`${styles.mini} ${styles.miniFlat} ${styles.miniGentle}`}>
        <span className={styles.ring} />
        <span>Listen to the line once more, then try again.</span>
      </div>
    ),
  },
  {
    title: 'Build sentences about your own life',
    text: 'At each stop you add one sentence about your own life. We call it your language island. By the end of the journey, you can talk about yourself fluently for about a minute.',
    image: '/landing/island.webp',
    alt: 'The language island in the app: filling the gaps of your first island line about yourself.',
    height: 1299,
    tone: 'mint',
    piece: (
      <div className={styles.mini}>
        <span className={styles.miniLabel}>Your island</span>
        <span className={styles.miniSpoken} lang="fi">
          Mä oon kotoisin Nigeriasta.
        </span>
        <span className={styles.miniWritten} lang="fi">
          Olen kotoisin Nigeriasta.
        </span>
      </div>
    ),
  },
  {
    title: 'Practise a real chat without the nerves',
    text: 'Along the journey, you meet Otso, your AI tutor, for short chats. He only uses words you’ve already learned, so you can keep up. Type your answer or say it out loud.',
    image: '/landing/otso.webp',
    alt: 'A short chat with Otso, the AI tutor, in the app, with the English meaning under each reply.',
    height: 1299,
    tone: 'peach',
    piece: (
      <div className={styles.mini}>
        <div className={styles.who}>
          <img src="/otso/avatar.webp" alt="" width={26} height={26} loading="lazy" />
          <span>Otso</span>
          <em>AI</em>
        </div>
        <span className={styles.miniSpoken} lang="fi">
          Mistä sä oot kotoisin?
        </span>
        <span className={styles.miniLabel}>Where are you from?</span>
      </div>
    ),
  },
  {
    title: 'Remember the words you learn',
    text: 'PuhuScribe brings each word back just before you would forget it, so it stays with you. You fill in the missing word in a line you’ve learned, and it sticks a little more each time.',
    image: '/landing/review.webp',
    alt: 'A review card in the app: the missing word typed in and marked right.',
    height: 1299,
    tone: 'mint',
    piece: (
      <div className={`${styles.mini} ${styles.miniFlat}`}>
        <span className={styles.tick}>
          <svg viewBox="0 0 24 24" focusable="false">
            <path d="M5 12.5l4.5 4.5L19 7.5" />
          </svg>
        </span>
        <span>
          <b lang="fi">maksaa</b> · Yes, that is right.
        </span>
      </div>
    ),
  },
]

function Features() {
  return (
    <div className={styles.features}>
      {FEATURES.map((feature, index) => (
        <section key={feature.title} className={styles.band} aria-labelledby={`feature-${String(index)}`}>
          <div className={styles.inner}>
            <div
              className={`${styles.feature} ${feature.tone === 'mint' ? styles.mint : styles.peach} ${index % 2 === 1 ? styles.flip : ''}`}
              data-reveal=""
            >
              <div className={styles.featureCopy}>
                <h2 id={`feature-${String(index)}`} className={styles.h3}>
                  {feature.title}
                </h2>
                <p className={styles.featureP}>{feature.text}</p>
              </div>
              <div className={styles.featureStage}>
                <div className={styles.phone}>
                  <img
                    src={feature.image}
                    alt={feature.alt}
                    width={600}
                    height={feature.height}
                    loading="lazy"
                    decoding="async"
                  />
                </div>
                <div className={styles.floatPiece} aria-hidden="true">
                  {feature.piece}
                </div>
              </div>
            </div>
          </div>
        </section>
      ))}
    </div>
  )
}

// The six parts of the road as signs on poles beside a straight road to the A1 sun, smaller toward
// the horizon (owner's design of 3 November 2026). The places are shares of the drawing, set in
// Landing.module.css.
const PARTS: readonly (readonly [string, string])[] = [
  ['First words', 'partFirst'],
  ['Daily life', 'partDaily'],
  ['Services', 'partServices'],
  ['Work and people', 'partWork'],
  ['Finnish life', 'partFinnish'],
  ['Getting things done', 'partDone'],
]

/** The six poles: x, top, bottom and stroke width, from the near sign to the far one. */
const POLES: readonly (readonly [number, number, number, number])[] = [
  [149, 382, 407, 2.4],
  [394, 344, 368, 2.3],
  [182, 307, 330, 2.2],
  [363, 274, 296, 2.1],
  [210, 244, 266, 2.0],
  [338, 218, 238, 2.0],
]

function JourneyRoad() {
  return (
    <div
      className={styles.roadArt}
      role="img"
      aria-label="A road leading to the A1 sun, through six parts: first words, daily life, services, work and people, Finnish life, getting things done"
    >
      <svg viewBox="0 0 560 420" xmlns="http://www.w3.org/2000/svg" focusable="false">
        <defs>
          <linearGradient id="journey-sky" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor="#e3f3ed" />
            <stop offset="1" stopColor="#fbefe6" />
          </linearGradient>
          <radialGradient id="journey-sun" cx="0.5" cy="0.5" r="0.5">
            <stop offset="0" stopColor="#fde4d8" />
            <stop offset="1" stopColor="#f4b496" />
          </radialGradient>
          <linearGradient id="journey-road" x1="0" y1="1" x2="0" y2="0">
            <stop offset="0" stopColor="#3d4a47" />
            <stop offset="1" stopColor="#6f7d79" />
          </linearGradient>
        </defs>
        <rect width="560" height="420" rx="32" fill="url(#journey-sky)" />
        <path
          d="M0 132 C 80 96, 150 100, 220 122 C 300 70, 380 72, 440 112 C 490 96, 530 100, 560 116 V420 H0Z"
          fill="#d3ebe2"
        />
        <circle cx="280" cy="150" r="62" fill="#fbe2d1" opacity=".75" />
        <path d="M240 150 A40 40 0 0 1 320 150 Z" fill="url(#journey-sun)" />
        <text
          x="280"
          y="138"
          textAnchor="middle"
          fontFamily="Poppins, sans-serif"
          fontWeight="600"
          fontSize="17"
          fill="#7f3618"
        >
          A1
        </text>
        <path d="M0 150 H560 V420 H0Z" fill="#cfeadf" />
        <g fill="#9fd3c0">
          <path d="M30 150 l8 -18 l8 18z" />
          <path d="M54 150 l7 -15 l7 15z" />
          <path d="M470 150 l8 -18 l8 18z" />
          <path d="M494 150 l7 -15 l7 15z" />
          <path d="M200 150 l5 -11 l5 11z" />
          <path d="M350 150 l5 -11 l5 11z" />
        </g>
        <path d="M150 420 L270 150 L290 150 L410 420 Z" fill="url(#journey-road)" />
        <path d="M280 154 L280 420" stroke="#ffffff" strokeWidth="3" strokeDasharray="14 12" opacity=".85" />
        {POLES.map(([x, top, bottom, width]) => (
          <line
            key={top}
            x1={x}
            y1={top}
            x2={x}
            y2={bottom}
            stroke="#9bbfb2"
            strokeWidth={width}
            strokeLinecap="round"
          />
        ))}
      </svg>
      <ul className={styles.roadSigns}>
        {PARTS.map(([name, place]) => (
          <li key={name} className={styles[place]}>
            {name}
          </li>
        ))}
      </ul>
    </div>
  )
}

function Journey() {
  return (
    <section className={`${styles.band} ${styles.journey}`} aria-labelledby="journey">
      <div className={styles.inner}>
        <div className={styles.journeyPanel} data-reveal="">
          <div>
            <h2 id="journey" className={styles.h2}>
              A journey made for life in Finland
            </h2>
            <p className={styles.journeyP}>
              It has 36 short stops, each one a moment you’ll meet here in Finland. Take them one at a time,
              and you’ll reach A1, the first everyday level of Finnish.
            </p>
          </div>
          <JourneyRoad />
        </div>
      </div>
    </section>
  )
}

const QUESTIONS: readonly (readonly [string, string])[] = [
  [
    'I already took a course. Is this for me?',
    'Yes. What you learned still counts. The early stops will feel familiar, and you’ll start to hear how Finns really say it.',
  ],
  [
    'How long does it take?',
    'One lesson takes about 10 to 15 minutes. With one a day, you reach A1 in about three and a half months. Two a day takes about eight weeks, and a whole stop a day about five. These are our estimates, since we haven’t measured them on real learners yet.',
  ],
  [
    'What level will I reach?',
    'Right now, the journey takes you from zero to A1, the first everyday level. That’s enough for simple everyday moments and for talking about yourself. The full journey is planned to go all the way to B2.',
  ],
  [
    'Do I need to sign up?',
    'No. Open it in your phone’s browser and start. Your progress is kept on your phone, and you can add an email later to keep it across devices.',
  ],
  [
    'What happens to my voice and data?',
    'Speech feedback is optional, and recordings aren’t kept by default. What PuhuScribe keeps is stored in the EU, and you can download or delete it any time. Chats with Otso are handled by an AI provider in the US and aren’t saved.',
  ],
]

function Questions() {
  return (
    <section className={styles.questions} aria-labelledby="questions">
      <div className={styles.inner}>
        <div className={styles.questionsGrid}>
          <h2 id="questions" className={styles.h2}>
            Questions
          </h2>
          <div className={styles.questionList}>
            {QUESTIONS.map(([question, answer]) => (
              <details key={question} className={styles.question} data-reveal="">
                <summary>{question}</summary>
                <p>{answer}</p>
              </details>
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}

function Close() {
  return (
    <section className={styles.close} aria-labelledby="close">
      <div className={styles.inner}>
        <h2 id="close" className={styles.closeTitle} data-reveal="">
          Your first fluent Finnish conversation is about ten minutes away
        </h2>
        <StartLink />
      </div>
    </section>
  )
}

function Footer() {
  return (
    <footer className={styles.footer}>
      <div className={`${styles.inner} ${styles.footerInner}`}>
        <span>© Exentrik</span>
        <a href={PATHS.privacy}>Privacy notice</a>
      </div>
    </footer>
  )
}

export function Landing() {
  useReveal()
  return (
    <div className={styles.page}>
      <main>
        <Hero />
        <Story />
        <Features />
        <Journey />
        <Questions />
        <Close />
      </main>
      <Footer />
    </div>
  )
}
