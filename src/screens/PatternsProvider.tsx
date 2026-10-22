import { useCallback, useRef, useState, type ReactNode } from 'react'
import { PatternsPanel, type PatternsState } from '../components/PatternsPanel.tsx'
import { callApi, isRecord } from '../lib/api.ts'
import type { PatternsAnswer } from '../lib/patterns-types.ts'
import { PatternsContext } from './patterns-context.ts'

// Gives the session's word cards their "Patterns you've seen" button and
// shows the panel on top of the card (factory/jobs/12-units-1-3/spec.md,
// "Done when" 9 to 14). The panel has no address of its own: it is not a
// page, a step or a menu item. Its data comes from GET /api/patterns with this
// session's id, fresh each time it opens.

function isAnswer(body: unknown): body is PatternsAnswer {
  return isRecord(body) && Array.isArray(body.groups)
}

interface PatternsProviderProps {
  sessionId: string
  children: ReactNode
}

export function PatternsProvider({ sessionId, children }: PatternsProviderProps) {
  const [opened, setOpened] = useState<{ formName: string; button: HTMLButtonElement } | null>(null)
  const [state, setState] = useState<PatternsState>({ kind: 'loading' })
  // Only the newest request may change what the panel shows.
  const request = useRef(0)

  const load = useCallback(() => {
    request.current += 1
    const mine = request.current
    setState({ kind: 'loading' })
    void callApi(`/api/patterns?session=${encodeURIComponent(sessionId)}`, 'GET').then((answer) => {
      if (mine !== request.current) return
      setState(
        answer?.status === 200 && isAnswer(answer.body)
          ? { kind: 'ready', answer: answer.body }
          : { kind: 'error' },
      )
    })
  }, [sessionId])

  const open = useCallback(
    (formName: string, button: HTMLButtonElement) => {
      setOpened({ formName, button })
      load()
    },
    [load],
  )

  function close() {
    const back = opened?.button
    request.current += 1
    setOpened(null)
    // Back to the button on the word card, once the panel has closed.
    if (back)
      setTimeout(() => {
        back.focus()
      }, 0)
  }

  return (
    <PatternsContext.Provider value={open}>
      {children}
      <PatternsPanel
        open={opened !== null}
        focusGroup={opened?.formName ?? null}
        state={state}
        onClose={close}
        onRetry={load}
      />
    </PatternsContext.Provider>
  )
}
