import { Component, type ReactNode } from 'react'
import { reportError } from '../lib/crash-reporter.ts'
import { Button } from './Button.tsx'
import { Landscape } from './Landscape.tsx'
import { StatusLine } from './StatusLine.tsx'
import styles from './CrashBoundary.module.css'

// The error boundary around the app (factory/jobs/14-analytics/spec.md, "Done
// when" 24). When a screen breaks while drawing, it reports the error and
// shows, in the problem style, one plain sentence and a Reload button.

export const SOMETHING_WENT_WRONG = 'Something went wrong on this screen.'

interface State {
  broken: boolean
}

/** The crash screen itself. `embedded` draws it inside a box (the reference page) instead of as the page. */
export function CrashScreen({ embedded = false }: { embedded?: boolean }) {
  const Root = embedded ? 'div' : 'main'
  const Title = embedded ? 'h3' : 'h1'
  return (
    <Root className={embedded ? `${styles.page} ${styles.embedded}` : styles.page}>
      <Landscape />
      <div className={styles.body}>
        <span className={styles.mark} aria-hidden="true">
          !
        </span>
        <Title className={styles.title}>Something went wrong</Title>
        {/* The title says it to the eye, once; this line says it to a screen reader, in the problem style. */}
        <StatusLine tone="problem" visuallyHidden>
          {SOMETHING_WENT_WRONG}
        </StatusLine>
        <Button
          block
          onClick={() => {
            window.location.reload()
          }}
        >
          Reload
        </Button>
      </div>
    </Root>
  )
}

export class CrashBoundary extends Component<{ children: ReactNode }, State> {
  state: State = { broken: false }

  static getDerivedStateFromError(): State {
    return { broken: true }
  }

  componentDidCatch(error: unknown): void {
    reportError(error)
  }

  render(): ReactNode {
    if (!this.state.broken) return this.props.children
    return <CrashScreen />
  }
}
