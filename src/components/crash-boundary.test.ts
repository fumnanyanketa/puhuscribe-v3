import type { ReactElement, ReactNode } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { describe, expect, it } from 'vitest'
import { CrashBoundary, SOMETHING_WENT_WRONG } from './CrashBoundary.tsx'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/19-redesign/spec.md.

function broken(): string {
  const boundary = new CrashBoundary({ children: null })
  boundary.state = { broken: true }
  return renderToStaticMarkup(boundary.render() as ReactElement)
}

describe('the screen that shows when a screen breaks', () => {
  it('[redesign 41] has the title, the existing sentence in the problem style and Reload', () => {
    const html = broken()
    expect(html).toContain('<h1')
    expect(html).toContain('Something went wrong</h1>')
    expect(html).toContain(SOMETHING_WENT_WRONG)
    expect(html).toContain('data-tone="problem"')
    expect(html).toContain('Reload')
  })

  it('[redesign 41] does not claim a report was sent, because a report goes only when it can', () => {
    const html = broken()
    expect(html).not.toMatch(/told about it|reported|we.ve been told|report was sent/i)
  })

  it('[redesign 41] shows the screen it wraps when nothing broke', () => {
    const boundary = new CrashBoundary({ children: 'fine' as ReactNode })
    expect(boundary.render()).toBe('fine')
  })
})
