import { useEffect, useState, type ReactNode } from 'react'
import { AnswerChoices } from '../components/AnswerChoices.tsx'
import { Button } from '../components/Button.tsx'
import { FinnishLine } from '../components/FinnishLine.tsx'
import { PlayControl, type PlayState } from '../components/PlayControl.tsx'
import { RecordControl, type RecordState } from '../components/RecordControl.tsx'
import { SessionFrame } from '../components/SessionFrame.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { Wordmark } from '../components/Wordmark.tsx'
import { contrast } from '../lib/contrast.ts'
import { CONTRAST_PAIRS } from '../styles/contrast-pairs.ts'
import { asMap, colourTokens } from '../styles/token-values.ts'
import tokensCss from '../styles/tokens.css?raw'
import {
  BROKEN_AUDIO,
  SECOND_TONE,
  SPOKEN_EXAMPLE,
  TONE,
  TYPE_SAMPLE_LETTERS,
  TYPE_SAMPLE_WORDS,
  WRITTEN_EXAMPLE,
} from './reference-content.ts'
import styles from './DesignReference.module.css'

// The design reference page (factory/jobs/5-design-system/spec.md, "Done
// when" 16): every design value and every screen part in every state, for the
// owner, the reviewers and the evaluator. Built only in development and in
// preview builds; no learner ever sees it. design.md explains each part.

const { light, dark } = colourTokens(tokensCss)
const LIGHT = asMap(light)
const DARK = asMap(dark)

const TEXT_SIZES = [
  ['--text-display', 'Reference page title', 'heading'],
  ['--text-title', 'Step name', 'heading'],
  ['--text-word-card', 'The word on its card', 'heading'],
  ['--text-line', 'A spoken Finnish line', 'heading'],
  ['--text-heading', 'Card and section headings', 'heading'],
  ['--text-written', 'The written line', 'body'],
  ['--text-body', 'Body text', 'body'],
  ['--text-small', 'Labels and notes', 'body'],
] as const

const SPACES = [
  '--space-1',
  '--space-2',
  '--space-3',
  '--space-4',
  '--space-5',
  '--space-6',
  '--space-7',
  '--space-8',
  '--space-9',
]
const RADII = ['--radius-word', '--radius-sm', '--radius-md', '--radius-lg', '--radius-xl', '--radius-pill']
const MOTION = [
  ['--motion-fast', 'Colour and opacity changes, button presses'],
  ['--motion-sheet', 'The word card rising from the bottom'],
] as const

function capitalise(word: string): string {
  return word.charAt(0).toUpperCase() + word.slice(1)
}

function SampleNote() {
  return <p className={styles.sampleNote}>Sample, not reviewed.</p>
}

const ANSWER_EXAMPLE = ['Good morning.', 'Where are you from?', 'Nice to meet you!']

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

function RecordDemo() {
  const [state, setState] = useState<RecordState>('ready')
  const [seconds, setSeconds] = useState(0)

  useEffect(() => {
    if (state === 'recording') {
      const timer = setInterval(() => {
        setSeconds((value) => value + 1)
      }, 1000)
      return () => {
        clearInterval(timer)
      }
    }
    if (state === 'working') {
      const timer = setTimeout(() => {
        setState('ready')
      }, 1500)
      return () => {
        clearTimeout(timer)
      }
    }
    return undefined
  }, [state])

  return (
    <RecordControl
      state={state}
      seconds={seconds}
      onStart={() => {
        setSeconds(0)
        setState('recording')
      }}
      onStop={() => {
        setState('working')
      }}
    />
  )
}

function BusyDemo() {
  const [busy, setBusy] = useState(false)
  useEffect(() => {
    if (!busy) return undefined
    const timer = setTimeout(() => {
      setBusy(false)
    }, 2000)
    return () => {
      clearTimeout(timer)
    }
  }, [busy])
  return (
    <Button
      variant="primary"
      busy={busy}
      busyLabel="Saving your answer."
      onClick={() => {
        setBusy(true)
      }}
    >
      Save
    </Button>
  )
}

export default function DesignReference() {
  return (
    <main className={styles.page}>
      <header className={styles.intro}>
        <Wordmark height={36} />
        <h1 className={styles.title}>Design reference</h1>
        <p className={styles.lead}>
          Every design value and screen part of PuhuScribe, in every state, for the owner, the reviewers and
          the evaluator. Learners never see this page. The rules behind each part are in design.md.
        </p>
        <p className={styles.lead}>
          The page follows your phone’s light or dark setting. The contrast tables show both.
        </p>
      </header>

      <Section id="colour" title="Colour">
        <ul className={styles.swatches}>
          {light.map((token) => (
            <li key={token.name} className={styles.swatch}>
              <span className={styles.chip} style={{ background: `var(${token.name})` }} />
              <span className={styles.swatchText}>
                <code>{token.name}</code>
                <span className={styles.quiet}>
                  Light {token.value}, dark {DARK.get(token.name) ?? ''}
                </span>
                {token.purpose && <span className={styles.quiet}>{token.purpose}</span>}
              </span>
            </li>
          ))}
        </ul>
        <h3 className={styles.subTitle}>Contrast, light and dark</h3>
        <div className={styles.tableWrap}>
          <table className={styles.table}>
            <thead>
              <tr>
                <th scope="col">Pairing</th>
                <th scope="col">Needs</th>
                <th scope="col">Light</th>
                <th scope="col">Dark</th>
              </tr>
            </thead>
            <tbody>
              {CONTRAST_PAIRS.map(({ fore, back, min, use }) => {
                const lightRatio = contrast(LIGHT.get(fore) ?? '', LIGHT.get(back) ?? '')
                const darkRatio = contrast(DARK.get(fore) ?? '', DARK.get(back) ?? '')
                const verdict = (ratio: number) =>
                  `${ratio.toFixed(1)}:1, ${ratio >= min ? 'passes' : 'fails'}`
                return (
                  <tr key={`${fore} ${back}`}>
                    <td>
                      {use}
                      <br />
                      <code className={styles.small}>
                        {fore} on {back}
                      </code>
                    </td>
                    <td>{min}:1</td>
                    <td>{verdict(lightRatio)}</td>
                    <td>{verdict(darkRatio)}</td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </Section>

      <Section id="type" title="Type">
        <p className={styles.lead}>
          Poppins for headings, buttons and Finnish lines. Switzer for body text. No italics. Sizes are in
          rem, so they follow the phone’s text size.
        </p>
        <ul className={styles.typeList}>
          {TEXT_SIZES.map(([token, use, family]) => (
            <li key={token}>
              <span
                className={family === 'heading' ? styles.typeHeading : styles.typeBody}
                style={{ fontSize: `var(${token})` }}
              >
                {use}
              </span>
              <code className={styles.small}>{token}</code>
            </li>
          ))}
        </ul>
        <h3 className={styles.subTitle}>Finnish type sample</h3>
        <SampleNote />
        <p className={styles.typeSampleLetters} lang="fi">
          {TYPE_SAMPLE_LETTERS}
        </p>
        <p className={styles.typeSampleLetters} lang="fi">
          <span className={styles.typeBody}>{TYPE_SAMPLE_LETTERS}</span>
        </p>
        {TYPE_SAMPLE_WORDS.map((word) => (
          <p key={word} className={styles.typeSampleWord} lang="fi">
            {word}
          </p>
        ))}
      </Section>

      <Section id="space" title="Spacing, corners and motion">
        <ul className={styles.spaceList}>
          {SPACES.map((token) => (
            <li key={token}>
              <span className={styles.spaceBar} style={{ width: `var(${token})` }} />
              <code className={styles.small}>{token}</code>
            </li>
          ))}
        </ul>
        <ul className={styles.radiusList}>
          {RADII.map((token) => (
            <li key={token}>
              <span className={styles.radiusBox} style={{ borderRadius: `var(${token})` }} />
              <code className={styles.small}>{token}</code>
            </li>
          ))}
        </ul>
        <ul className={styles.plainList}>
          {MOTION.map(([token, use]) => (
            <li key={token}>
              <code>{token}</code>: {use}. With reduce motion on, nothing slides or scales.
            </li>
          ))}
        </ul>
      </Section>

      <Section id="frame" title="Session frame">
        <p className={styles.lead}>
          The step named in words, Leave session, a scrolling content area and the actions kept at the bottom.
        </p>
        <SampleNote />
        <div className={styles.frameBox}>
          <SessionFrame
            step="Hear it"
            hasUseIt
            leaveHref="/design-reference"
            contained
            actions={
              <div className={styles.actionRow}>
                <PlayControl src={TONE} what="the dialogue" />
                <Button variant="primary" block>
                  Continue
                </Button>
              </div>
            }
          >
            <h3 className={styles.frameTitle}>Hear it</h3>
            <div className={styles.card}>
              <FinnishLine
                cardNote="Sample, not reviewed."
                spoken={SPOKEN_EXAMPLE}
                written={WRITTEN_EXAMPLE}
                current={1}
              />
            </div>
          </SessionFrame>
        </div>
      </Section>

      <Section id="buttons" title="Buttons">
        {(['primary', 'secondary', 'quiet'] as const).map((variant) => (
          <div key={variant} className={styles.stateGroup}>
            <h3 className={styles.subTitle}>{capitalise(variant)}</h3>
            <div className={styles.stateRow}>
              <figure className={styles.state}>
                <Button variant={variant}>Continue</Button>
                <figcaption>Ready</figcaption>
              </figure>
              <figure className={styles.state}>
                <Button variant={variant} showState="hover">
                  Continue
                </Button>
                <figcaption>Hover</figcaption>
              </figure>
              <figure className={styles.state}>
                <Button variant={variant} showState="pressed">
                  Continue
                </Button>
                <figcaption>Pressed</figcaption>
              </figure>
              <figure className={styles.state}>
                <Button variant={variant} disabled>
                  Continue
                </Button>
                <figcaption>Disabled</figcaption>
              </figure>
              <figure className={styles.state}>
                <Button variant={variant} busy busyLabel="Saving your answer.">
                  Continue
                </Button>
                <figcaption>Busy</figcaption>
              </figure>
            </div>
          </div>
        ))}
        <p className={styles.lead}>
          Focus shows on any control when you move to it with a keyboard. This button shows the busy state for
          two seconds.
        </p>
        <BusyDemo />
      </Section>

      <Section id="status" title="Status line">
        <div className={styles.stack}>
          <StatusLine tone="neutral">Saving your answer.</StatusLine>
          <StatusLine tone="gentle">Close. Try the double k.</StatusLine>
          <StatusLine tone="problem">No connection. Check your internet, then try again.</StatusLine>
        </div>
      </Section>

      <Section id="answers" title="Answer choices">
        <p className={styles.lead}>One row per English meaning. Each list shows one state.</p>
        <div className={styles.stack}>
          {(
            [
              ['answers-ready', 'Ready', new Set<number>(), null],
              ['answers-wrong', 'After a choice that is not right', new Set([1]), null],
              ['answers-right', 'After the right choice', new Set([1]), 0],
            ] as const
          ).map(([id, title, tried, right]) => (
            <div key={id}>
              <h3 id={id} className={styles.lead}>
                {title}
              </h3>
              <AnswerChoices
                choices={ANSWER_EXAMPLE}
                unavailable={tried}
                right={right}
                onChoose={() => undefined}
                labelledBy={id}
              />
            </div>
          ))}
        </div>
      </Section>

      <Section id="line" title="Finnish line and word card">
        <p className={styles.lead}>Tap a word to open its card.</p>
        <SampleNote />
        <div className={styles.card}>
          <FinnishLine cardNote="Sample, not reviewed." spoken={SPOKEN_EXAMPLE} written={WRITTEN_EXAMPLE} />
        </div>
      </Section>

      <Section id="play" title="Play control">
        <p className={styles.lead}>These play a short tone, not speech.</p>
        <div className={styles.stateRow}>
          <figure className={styles.state}>
            <PlayControl src={TONE} what="the first tone" />
            <figcaption>Live</figcaption>
          </figure>
          <figure className={styles.state}>
            <PlayControl src={SECOND_TONE} what="the second tone" />
            <figcaption>Live, stops the other</figcaption>
          </figure>
          <figure className={styles.state}>
            <PlayControl src={BROKEN_AUDIO} what="a broken file" />
            <figcaption>Live, cannot play</figcaption>
          </figure>
        </div>
        <div className={styles.stateRow}>
          {(['ready', 'loading', 'playing', 'error'] as PlayState[]).map((state) => (
            <figure key={state} className={styles.state}>
              <PlayControl src={TONE} what={`the ${state} example`} showState={state} />
              <figcaption>{state === 'error' ? 'Could not play' : capitalise(state)}</figcaption>
            </figure>
          ))}
        </div>
      </Section>

      <Section id="record" title="Record control">
        <p className={styles.lead}>Look only. Nothing is recorded and the microphone is never asked for.</p>
        <div className={styles.stack}>
          <RecordControl state="ready" />
          <RecordControl state="recording" seconds={3} />
          <RecordControl state="working" />
          <RecordControl state="unavailable" reason="This browser cannot record sound." />
        </div>
        <h3 className={styles.subTitle}>Try the states</h3>
        <RecordDemo />
      </Section>
    </main>
  )
}
