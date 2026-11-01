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
    return (
      <main className={styles.page}>
        <Landscape />
        <div className={styles.body}>
          <span className={styles.mark} aria-hidden="true">
            !
          </span>
          <h1 className={styles.title}>Something went wrong</h1>
          <StatusLine tone="problem">{SOMETHING_WENT_WRONG}</StatusLine>
          <Button
            block
            onClick={() => {
              window.location.reload()
            }}
          >
            Reload
          </Button>
        </div>
      </main>
    )
  }
}
