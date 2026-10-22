import { describe, expect, it } from 'vitest'
import type { SessionRow } from './learner-db.ts'
import { audioPath, pickToday, sessionLines, splitLine } from './session-plan.ts'
import { sampleContent, sampleDialogue } from './test-fakes.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/8-first-session/spec.md that each test protects.

function session(dialogueId: number, endedAt: string | null, startedAt = '2026-10-21T10:00:00Z'): SessionRow {
  return { id: `s-${String(dialogueId)}-${startedAt}`, dialogueId, step: null, startedAt, endedAt }
}

describe("today's dialogue", () => {
  const dialogues = [sampleDialogue(30, 2, 1), sampleDialogue(20, 1, 2), sampleDialogue(10, 1, 1)]

  it('[session 6] is the lowest unit position, then the lowest dialogue position', () => {
    const pick = pickToday(dialogues, [])
    expect(pick.kind === 'dialogue' && pick.dialogue.id).toBe(10)
  })

  it('[session 6] skips finished dialogues', () => {
    const pick = pickToday(dialogues, [session(10, '2026-10-21T11:00:00Z')])
    expect(pick.kind === 'dialogue' && pick.dialogue.id).toBe(20)
  })

  it('[session 6] [session 18] reuses the newest unfinished session of that dialogue', () => {
    const older = session(10, null, '2026-10-20T10:00:00Z')
    const newer = session(10, null, '2026-10-21T10:00:00Z')
    const pick = pickToday(dialogues, [older, newer, session(20, null)])
    expect(pick.kind === 'dialogue' && pick.open?.id).toBe(newer.id)
  })

  it('[session 6] is all_done when every dialogue is finished, and not_ready when none is readable', () => {
    const done = dialogues.map((d) => session(d.id, '2026-10-21T11:00:00Z'))
    expect(pickToday(dialogues, done)).toEqual({ kind: 'all_done' })
    expect(pickToday([], [])).toEqual({ kind: 'not_ready' })
  })
})

describe('splitting a line into its words', () => {
  it('[session 9] keeps punctuation with the word before it', () => {
    expect(
      splitLine('Moi! Mä oon Alex.', [
        { surface: 'Moi' },
        { surface: 'Mä' },
        { surface: 'oon' },
        { surface: 'Alex' },
      ]),
    ).toEqual([{ text: 'Moi', after: '!' }, { text: 'Mä' }, { text: 'oon' }, { text: 'Alex', after: '.' }])
  })

  it('[session 9] keeps punctuation before the first word', () => {
    expect(splitLine('"Moi!"', [{ surface: 'Moi' }])).toEqual([{ text: 'Moi', before: '"', after: '!"' }])
  })

  it('[session 9] refuses a line whose words are not all found, in order', () => {
    expect(splitLine('Mä oon Alex.', [{ surface: 'oon' }, { surface: 'Mä' }])).toBeNull()
    expect(splitLine('Mä oon Alex.', [{ surface: 'Mä' }, { surface: 'Alex' }])).toBeNull()
    expect(splitLine('Mä oon Alex.', [{ surface: 'Mä' }, { surface: 'oon' }])).toBeNull()
    expect(splitLine('Mä oon', [])).toBeNull()
  })

  it('[session 9] [session 12] builds both registers, with cards only for readable forms', () => {
    const lines = sessionLines(sampleContent())
    expect(lines.map((l) => l.id)).toEqual([11, 12])
    expect(lines[0]?.spoken.filter((w) => w.form).map((w) => w.text)).toEqual(['Moi', 'Mä', 'oon'])
    expect(lines[1]?.written.filter((w) => w.form).map((w) => w.text)).toEqual(['Hauska'])
  })
})

describe('audio paths', () => {
  it('[session 10] are /audio/<key> on the same address, with each part encoded', () => {
    expect(audioPath('unit-1-dialogue-1/1-puhe-0123456789ab.mp3')).toBe(
      '/audio/unit-1-dialogue-1/1-puhe-0123456789ab.mp3',
    )
    expect(audioPath('a b/c.mp3')).toBeNull()
  })

  it('[session 10] refuse a key that could leave the /audio/ folder or name another address', () => {
    for (const key of [
      '../secret.mp3',
      'a/../b.mp3',
      '/abs.mp3',
      'https://x.example/a.mp3',
      '',
      'a//b.mp3',
      './a.mp3',
    ]) {
      expect(audioPath(key), key).toBeNull()
    }
  })
})
