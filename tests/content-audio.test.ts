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
    expect(
      checkPublishedAudio('public/audio', 'supabase/migrations', 'content/approvals', 'content/word-audio', {
        data: 'src/lib/islands-data.json',
        sourceDir: 'content/island-audio',
      }),
    ).toEqual([])
    // Reads and hashes every published clip (about 3,800 files), which can pass 5 seconds on a busy machine.
  }, 60_000)

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

  // Fast route aleksi-intro (4 November 2026): Aleksi's greeting is served only with the owner's written
  // approval in content/approvals/aleksi-greeting.json, which names the file and its SHA-256.
  describe("Aleksi's greeting", () => {
    const file = 'aleksi/greeting-0123456789ab.mp3'
    const refused = `${file} is not the greeting the owner approved (content/approvals/aleksi-greeting.json)`
    const approved = {
      format: 'puhuscribe-owner-approval-aleksi-greeting-1',
      approval: 'approved',
      date: '2026-11-04',
      file,
      sha256: sha('greeting'),
    }

    function greetingSandbox(opts: { files?: Record<string, string>; approval?: object | null }) {
      const { audio, migrations } = sandbox({}, [])
      const approvals = join(audio, '..', '..', 'content', 'approvals')
      mkdirSync(approvals, { recursive: true })
      mkdirSync(join(audio, 'aleksi'), { recursive: true })
      const approval = opts.approval === undefined ? approved : opts.approval
      if (approval) writeFileSync(join(approvals, 'aleksi-greeting.json'), JSON.stringify(approval))
      for (const [name, bytes] of Object.entries(opts.files ?? { [file]: 'greeting' }))
        writeFileSync(join(audio, name), bytes)
      return checkPublishedAudio(audio, migrations, approvals)
    }

    it('[aleksi-intro 3] the approved greeting with its approved bytes passes', () => {
      expect(greetingSandbox({})).toEqual([])
    })

    it('[aleksi-intro 3] without the owner approval the greeting fails', () => {
      expect(greetingSandbox({ approval: null })).toEqual([refused])
    })

    it('[aleksi-intro 3] an approval with no owner line, or no date, approves nothing', () => {
      expect(greetingSandbox({ approval: { ...approved, approval: ' ' } })).toEqual([refused])
      expect(greetingSandbox({ approval: { ...approved, date: 'today' } })).toEqual([refused])
    })

    it('[aleksi-intro 3] swapped bytes, a second clip and a missing file each fail', () => {
      expect(greetingSandbox({ files: { [file]: 'another voice' } })).toEqual([
        `${file} differs from the approved greeting (its SHA-256 differs)`,
      ])
      const other = 'aleksi/greeting-ba9876543210.mp3'
      expect(greetingSandbox({ files: { [file]: 'greeting', [other]: 'x' } })).toEqual([
        `${other} is not the greeting the owner approved (content/approvals/aleksi-greeting.json)`,
      ])
      expect(greetingSandbox({ files: {} })).toEqual([`${file} is approved but its file is missing`])
    })
  })

  // Fast route "islands" (3 November 2026): island clips are approved through the island data, and
  // only while that data was made from the islands.md the owner approved. Before this full run the
  // check did not know the islands/ folder, so every island clip failed it.
  describe('island clips', () => {
    const k1 = sha('island one')
    const k2 = sha('island two')
    const k3 = sha('island closing')
    const k4 = sha('island closing written')
    const approvedSha = sha('islands.md as approved')

    function islandSandbox(opts: {
      files?: Record<string, string>
      dataSha?: string
      source?: Record<string, string>
    }) {
      const { audio, migrations } = sandbox({}, [])
      const root = join(audio, '..', '..')
      const approvals = join(root, 'content', 'approvals')
      const source = join(root, 'content', 'island-audio')
      mkdirSync(approvals, { recursive: true })
      mkdirSync(source, { recursive: true })
      mkdirSync(join(audio, 'islands'), { recursive: true })
      writeFileSync(
        join(approvals, 'islands.json'),
        JSON.stringify({ format: 'puhuscribe-owner-approval-islands-1', sha256: approvedSha }),
      )
      const data = join(root, 'islands-data.json')
      writeFileSync(
        data,
        JSON.stringify({
          format: 'puhuscribe-islands-1',
          source_sha256: opts.dataSha ?? approvedSha,
          stops: [{ audio: [{ spoken: k1, written: k2 }] }],
          closing: { audio: { spoken: k3, written: k4 } },
        }),
      )
      const all = { [k1]: 'one', [k2]: 'two', [k3]: 'three', [k4]: 'four' }
      for (const [name, bytes] of Object.entries(opts.files ?? all))
        writeFileSync(join(audio, 'islands', `${name}.mp3`), bytes)
      for (const [name, bytes] of Object.entries(opts.source ?? all))
        writeFileSync(join(source, `${name}.mp3`), bytes)
      return checkPublishedAudio(audio, migrations, approvals, undefined, { data, sourceDir: source })
    }

    it('[content 17] every clip the approved island data lists, matching its source, passes', () => {
      expect(islandSandbox({})).toEqual([])
    })

    it('[content 17] an island clip the island data does not list fails', () => {
      const other = sha('not an island line')
      expect(
        islandSandbox({ files: { [k1]: 'one', [k2]: 'two', [k3]: 'three', [k4]: 'four', [other]: 'x' } }),
      ).toEqual([`islands/${other}.mp3 is not an island clip of the approved island lines`])
    })

    it('[content 17] an island clip whose bytes differ from content/island-audio fails', () => {
      expect(
        islandSandbox({ source: { [k1]: 'swapped', [k2]: 'two', [k3]: 'three', [k4]: 'four' } }),
      ).toEqual([`islands/${k1}.mp3 differs from its clip in content/island-audio/`])
    })

    it('[content 17] an approved island key without its file fails', () => {
      expect(islandSandbox({ files: { [k1]: 'one', [k2]: 'two', [k3]: 'three' } })).toEqual([
        `islands/${k4}.mp3 is approved but its file is missing`,
      ])
    })

    it('[content 17] island data not made from the approved islands.md approves no clip', () => {
      const problems = islandSandbox({ dataSha: sha('an edited islands.md') })
      expect(problems).toHaveLength(4)
      for (const problem of problems)
        expect(problem).toMatch(/is not an island clip of the approved island lines$/)
    })
  })

  it('[content 17] nothing under content/ reaches the built app', () => {
    const vite = readFileSync('vite.config.ts', 'utf8')
    expect(vite).not.toMatch(/publicDir/)
    const appFiles = ['src', 'worker'].flatMap((dir) =>
      readdirSync(dir, { recursive: true, encoding: 'utf8' }).map((file) => join(dir, file)),
    )
    // Job 10-speaking-feedback ("Done when" 10): the speaking feedback rules
    // read their numbers from content/checks/speech-thresholds.json, which
    // holds only numbers (no Finnish, nothing waiting for review). That one
    // import in that one file is allowed; everything else stays out.
    const thresholds = /^src[\\/]lib[\\/]speech-feedback\.ts$/
    // Fast route "islands" (3 November 2026): src/lib/islands.ts reads the owner's approval record,
    // content/approvals/islands.json, which holds only a file name, its SHA-256, the approval line and
    // the date (no Finnish, nothing waiting for review), so it can refuse island data made from any
    // other file. That one import in that one file is allowed as well.
    const islandApproval = /^src[\\/]lib[\\/]islands\.ts$/
    // Job 16-tutor-step ("Done when" 12 to 15): the tutor's word and phrase rules read their numbers
    // from content/checks/tutor-thresholds.json, which also holds only numbers and a note in English.
    const tutorThresholds = /^src[\\/]lib[\\/]tutor-words\.ts$/
    const allowed = (file: string, text: string) => {
      if (thresholds.test(file)) return text.replace("from '../../content/checks/speech-thresholds.json'", '')
      if (islandApproval.test(file)) return text.replace("from '../../content/approvals/islands.json'", '')
      if (tutorThresholds.test(file))
        return text.replace("from '../../content/checks/tutor-thresholds.json'", '')
      return text
    }
    for (const file of appFiles.filter((f) => /\.(ts|tsx|css|html)$/.test(f))) {
      const text = readFileSync(file, 'utf8')
      expect(allowed(file, text), file).not.toMatch(
        /['"`](\.\.\/)+content\/|['"`]\/?content\/(briefs|drafts|reviews|recordings|logs|checks)/,
      )
    }
    // public/ holds only the published audio, and since jobs 16-tutor-step and 17-landing-page
    // Otso's picture (otso/), the landing page's pictures (landing/) and robots.txt, and since fast
    // route aleksi-intro Aleksi's portrait (aleksi/), and since fast route road-stops the stop pictures
    // (stops/; their source and licence are in design/stop-pictures/README.md, so the folder stays images
    // only). Those folders hold images only, so no text from content/ can travel through them.
    const publicEntries = existsSync('public') ? readdirSync('public') : []
    expect(publicEntries.filter((name) => name !== 'audio').sort()).toEqual([
      'aleksi',
      'landing',
      'otso',
      'robots.txt',
      'stops',
    ])
    for (const dir of ['aleksi', 'landing', 'otso', 'stops'])
      for (const name of readdirSync(join('public', dir))) expect(name, dir).toMatch(/\.(webp|svg)$/)
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
    // Job 10-speaking-feedback ("Done when" 12) puts the one speech to text
    // provider in worker/providers/speech-feedback.ts. That module and its own
    // unit test may name Azure's speech to text address and key; they still
    // may not call an AI service or a voice (text to speech) service.
    // tests/speech-provider-rules.test.ts proves no other file does.
    const speechProvider = /^worker[\\/]providers[\\/]speech-feedback(\.test)?\.ts$/
    // Job 16-tutor-step ("Done when" 26 and 27, owner's call of 3 November 2026) adds Otso, whose one
    // AI provider is worker/providers/ai.ts: that module alone may use Anthropic's SDK, its address
    // and its key. The privacy notice and the consent texts name Anthropic as the processor in plain
    // words, so the company name alone is no longer refused; its address, SDK and key still are, in
    // every other file, and no browser file names any of them.
    const aiProvider = /^worker[\\/]providers[\\/]ai\.ts$/
    const ai = /api\.anthropic|@anthropic-ai|ANTHROPIC_API_KEY/i
    const voice = /speech\.microsoft\.com|cognitiveservices|tts\.speech|AZURE_SPEECH/i
    for (const file of files) {
      const text = readFileSync(file, 'utf8')
      if (!aiProvider.test(file)) expect(text, file).not.toMatch(ai)
      expect(text, file).not.toMatch(speechProvider.test(file) ? /tts\.speech/i : voice)
    }
    // The AI provider calls no voice service.
    expect(readFileSync('worker/providers/ai.ts', 'utf8')).not.toMatch(voice)
  })
})
