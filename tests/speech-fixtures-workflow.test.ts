import { readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.
// The manual workflow that replaces the hand-built fixtures with Azure's real
// answers. Read as text, as tests/checks-workflow.test.ts does.

const workflow = readFileSync('.github/workflows/speech-fixtures.yml', 'utf8').replace(/\r\n/g, '\n')

/** Each step's text, from one "- " at six spaces to the next. */
function steps(text: string): string[] {
  return text
    .slice(text.indexOf('    steps:\n'))
    .split(/\n(?= {6}- )/)
    .slice(1)
}

describe('the Speech fixtures workflow', () => {
  it('[speak 23] runs only when started by hand', () => {
    const on = workflow.slice(workflow.indexOf('\non:\n'), workflow.indexOf('\npermissions:'))
    expect(on.trim()).toBe('on:\n  workflow_dispatch:')
  })

  it('[speak 23] voices the fixture lines with the pipeline voice module, then sends them through the speech provider', () => {
    const all = steps(workflow)
    const voice = all.findIndex((s) => s.includes('python scripts/speech/voice_fixture_lines.py'))
    const record = all.findIndex((s) => s.includes('node scripts/speech/record-fixtures.ts'))
    expect(voice).toBeGreaterThan(-1)
    expect(record).toBeGreaterThan(voice)
    expect(all[voice]).toContain('VOICE_PROVIDER: azure')
    expect(all[record]).toContain('SPEECH_FEEDBACK_PROVIDER: azure')
  })

  it('[speak 23] passes the key only to the steps that call Azure and to the check of the new files', () => {
    const withKey = steps(workflow).filter((s) => s.includes('secrets.AZURE_SPEECH_KEY'))
    expect(withKey).toHaveLength(3)
    expect(withKey[2]).toContain('node scripts/ci/check-files-for-secrets.ts')
    expect(withKey[2]).toContain('--env AZURE_SPEECH_KEY')
    expect(workflow.slice(0, workflow.indexOf('\njobs:\n'))).not.toContain('secrets.')
    expect(workflow).not.toMatch(/^ +(- )?(run: )?npm (ci|install)/m)
  })

  it('[speak 23] checks the files for the key before it commits them, and only that step holds the GitHub token', () => {
    const all = steps(workflow)
    const guard = all.findIndex((s) => s.includes('check-files-for-secrets.ts'))
    const commit = all.findIndex((s) => s.includes('git commit'))
    expect(guard).toBeGreaterThan(-1)
    expect(commit).toBeGreaterThan(guard)
    expect(all.filter((s) => s.includes('github.token'))).toEqual([all[commit]])
    expect(all[commit]).toContain('git add worker/providers/fixtures/speech content/logs/ai-calls.jsonl')
    expect(workflow).toContain('persist-credentials: false')
  })
})
