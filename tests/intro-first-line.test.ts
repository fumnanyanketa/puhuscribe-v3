import { existsSync, readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'
import { FIRST_DIALOGUE_SLUG, FIRST_LINE_AUDIO, FIRST_LINE_AUDIO_KEY } from '../src/lib/intro-first-line.ts'

// The recap card plays the first spoken line of the first dialogue (fast route
// "intro", item 2). These tests tie the named file to the published content,
// so a change to the content turns them red instead of playing the wrong line.

const MIGRATIONS = 'supabase/migrations'
const sqlFiles = readdirSync(MIGRATIONS)
  .filter((name) => name.endsWith('.sql'))
  .sort()
  .map((name) => ({ name, sql: readFileSync(join(MIGRATIONS, name), 'utf8') }))

describe('the recap card plays the real first line', () => {
  it('[intro 2] the first dialogue of stop 1 is the one named, and no other migration puts a dialogue first', () => {
    const firsts = sqlFiles.flatMap(({ sql }) =>
      [
        ...sql.matchAll(
          /insert into public\.dialogues \(unit_id, slug, position, title_en\)\s+values \(v_unit_id, '([^']+)', 1,/g,
        ),
      ]
        .map((match) => match[1])
        .filter((slug) => slug?.startsWith('meeting-people-')),
    )
    expect(firsts).toEqual([FIRST_DIALOGUE_SLUG])
    const publish = sqlFiles.find(({ sql }) =>
      sql.includes(`values (v_unit_id, '${FIRST_DIALOGUE_SLUG}', 1,`),
    )
    expect(publish?.sql).toMatch(/where slug = 'meeting-people' and position = 1 and stop_number = 1/)
  })

  it('[intro 2] the audio is the spoken file of line 1 of that dialogue', () => {
    const publish = sqlFiles.find(({ sql }) =>
      sql.includes(`values (v_unit_id, '${FIRST_DIALOGUE_SLUG}', 1,`),
    )
    const line1 = publish?.sql.match(
      /insert into public\.dialogue_lines \([^)]*\)\s+values \(v_dialogue_id, 1, [\s\S]*?'([^']+-puhe-[0-9a-f]+\.mp3)', '[^']+-kirja-[0-9a-f]+\.mp3'\)/,
    )
    expect(line1?.[1]).toBe(FIRST_LINE_AUDIO_KEY)
    expect(FIRST_LINE_AUDIO).toBe(`/audio/${FIRST_LINE_AUDIO_KEY}`)
    // Its line keeps the same key in every later migration that names it.
    for (const { sql } of sqlFiles) {
      for (const match of sql.matchAll(/'(meeting-people-new-colleague\/1-puhe-[0-9a-f]+\.mp3)'/g)) {
        expect(match[1]).toBe(FIRST_LINE_AUDIO_KEY)
      }
    }
  })

  it('[intro 2] the file is served by the app and the dialogue is owner approved', () => {
    expect(existsSync(join('public', 'audio', ...FIRST_LINE_AUDIO_KEY.split('/')))).toBe(true)
    const approvals = JSON.parse(readFileSync('content/approvals/part-1.json', 'utf8')) as {
      dialogues: Record<string, string>
    }
    expect(Object.keys(approvals.dialogues)).toContain(FIRST_DIALOGUE_SLUG)
  })
})
