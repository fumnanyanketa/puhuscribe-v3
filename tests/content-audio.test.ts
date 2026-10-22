import { createHash } from 'node:crypto'
import { existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'
import { checkPublishedAudio, publishedKeys } from '../scripts/ci/check-published-audio.ts'

// Labels [content N] are the "Done when" statement numbers from
// factory/jobs/7-content-pipeline/spec.md that each test protects.

const sha = (data: string) => createHash('sha256').update(data).digest('hex')

function sandbox(clips: Record<string, string>, published: string[]) {
  const root = mkdtempSync(join(tmpdir(), 'audio-check-'))
  const audio = join(root, 'public', 'audio')
  const migrations = join(root, 'supabase', 'migrations')
  mkdirSync(migrations, { recursive: true })
  for (const [key, data] of Object.entries(clips)) {
    mkdirSync(join(audio, key.split('/')[0] ?? ''), { recursive: true })
    writeFileSync(join(audio, key), data)
  }
  const values = published.map((key) => `'${key}'`).join(', ')
  writeFileSync(join(migrations, '20261021120000_publish_some_dialogue.sql'), `-- test\nselect ${values};\n`)
  return { audio, migrations }
}

const clip = 'line one audio'
const key = `some-dialogue/1-puhe-${sha(clip).slice(0, 12)}.mp3`

describe('audio exists only for approved lines', () => {
  it('[content 17] the repository: every file under public/audio is a published key with a matching hash, and every key has its file', () => {
    expect(checkPublishedAudio('public/audio', 'supabase/migrations')).toEqual([])
  })

  it('[content 17] a matching file and key pass', () => {
    const { audio, migrations } = sandbox({ [key]: clip }, [key])
    expect(publishedKeys(migrations)).toEqual(new Set([key]))
    expect(checkPublishedAudio(audio, migrations)).toEqual([])
  })

  it('[content 17] a file no publish migration names fails', () => {
    const { audio, migrations } = sandbox({ [key]: clip, 'other/1-kirja-000000000000.mp3': 'x' }, [key])
    expect(checkPublishedAudio(audio, migrations)).toEqual([
      'other/1-kirja-000000000000.mp3 is not the audio of a line any publish migration approves',
    ])
  })

  it('[content 17] a file whose SHA-256 does not match its name fails', () => {
    const { audio, migrations } = sandbox({ [key]: 'swapped audio' }, [key])
    expect(checkPublishedAudio(audio, migrations)).toEqual([
      `${key} does not match its name (its SHA-256 differs)`,
    ])
  })

  it('[content 17] a published key without its file fails', () => {
    const { audio, migrations } = sandbox({}, [key])
    expect(checkPublishedAudio(audio, migrations)).toEqual([
      `${key} is published but public/audio/${key} is missing`,
    ])
  })

  it('[content 17] nothing under content/ reaches the built app', () => {
    const vite = readFileSync('vite.config.ts', 'utf8')
    expect(vite).not.toMatch(/publicDir/)
    const appFiles = ['src', 'worker'].flatMap((dir) =>
      readdirSync(dir, { recursive: true, encoding: 'utf8' }).map((file) => join(dir, file)),
    )
    for (const file of appFiles.filter((f) => /\.(ts|tsx|css|html)$/.test(f))) {
      expect(readFileSync(file, 'utf8'), file).not.toMatch(
        /['"`](\.\.\/)+content\/|['"`]\/?content\/(briefs|drafts|reviews|recordings|logs|checks)/,
      )
    }
    // public/ holds only the published audio.
    const publicEntries = existsSync('public') ? readdirSync('public') : []
    expect(publicEntries.filter((name) => name !== 'audio')).toEqual([])
  })
})

describe('the shared shape is untouched', () => {
  const ddl =
    /\b(create|alter|drop)\s+(table|type|function|policy|schema|trigger|view|role)\b|\bgrant\b|\brevoke\b/i

  it('[content 19] publish migrations add no table, column, type, rule, grant or function', () => {
    const files = readdirSync('supabase/migrations').filter((name) => name.includes('_publish_'))
    for (const name of files)
      expect(readFileSync(join('supabase/migrations', name), 'utf8'), name).not.toMatch(ddl)
    const fixture = readFileSync('supabase/tests/database/content_publish.test.sql', 'utf8')
    const publishBlocks = fixture.split('$migration$').filter((_part, i) => i % 2 === 1)
    expect(publishBlocks).toHaveLength(2)
    for (const block of publishBlocks) expect(block).not.toMatch(ddl)
  })

  it('[content 19] no /api route and no browser code calls an AI or voice service', () => {
    const files = ['src', 'worker'].flatMap((dir) =>
      readdirSync(dir, { recursive: true, encoding: 'utf8' })
        .filter((file) => /\.(ts|tsx)$/.test(file))
        .map((file) => join(dir, file)),
    )
    expect(files.length).toBeGreaterThan(5)
    for (const file of files) {
      expect(readFileSync(file, 'utf8'), file).not.toMatch(
        /anthropic|api\.anthropic|speech\.microsoft\.com|cognitiveservices|tts\.speech|AZURE_SPEECH|ANTHROPIC_API_KEY/i,
      )
    }
  })
})
