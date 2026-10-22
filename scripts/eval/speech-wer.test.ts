import { execFileSync } from 'node:child_process'
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { describe, expect, it } from 'vitest'
import type { HeardAnswer } from '../../src/lib/speech-feedback.ts'
import { encodeWav } from '../../src/lib/wav.ts'
import { clipFolderProblem } from './clip-folder.ts'
import { parseManifest, reportLines, werReport, wordErrors, type ClipEntry } from './speech-wer.ts'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/10-speaking-feedback/spec.md that each test protects.
// The word error harness, run on five generated tone clips (never speech)
// with recorded fake answers, so every number below is known exactly.

function toneClip(seconds: number): Uint8Array {
  const samples = new Float32Array(Math.round(seconds * 16_000))
  for (let i = 0; i < samples.length; i += 1) samples[i] = 0.3 * Math.sin((2 * Math.PI * 440 * i) / 16_000)
  return encodeWav(samples)
}

const CLIPS: ClipEntry[] = [
  {
    file: 'clip-1.wav',
    spoken: 'Moi! Mä oon Alex.',
    written: 'Hei! Minä olen Alex.',
    reviewer: 'correct',
    lengthMistakePlanted: false,
  },
  {
    file: 'clip-2.wav',
    spoken: 'Kiva tavata!',
    written: 'Hauska tavata!',
    reviewer: 'not_correct',
    where: 'tavata',
    lengthMistakePlanted: false,
  },
  {
    file: 'clip-3.wav',
    spoken: 'Paljonks se maksaa?',
    written: 'Paljonko se maksaa?',
    reviewer: 'correct',
    lengthMistakePlanted: false,
  },
  {
    file: 'clip-4.wav',
    spoken: 'Moi! Mä oon Alex.',
    written: 'Hei! Minä olen Alex.',
    reviewer: 'not_correct',
    where: 'oon said short',
    lengthMistakePlanted: true,
  },
  {
    file: 'clip-5.wav',
    spoken: 'Onks teil kauramaitoo?',
    written: 'Onko teillä kauramaitoa?',
    reviewer: 'not_correct',
    where: 'kauramaitoo said short',
    lengthMistakePlanted: true,
  },
]

// What the fake service "heard" for each clip, recorded by hand.
const HEARD: Record<string, HeardAnswer> = {
  'clip-1.wav': { status: 'heard', heard: 'moi mä oon alex' },
  'clip-2.wav': { status: 'heard', heard: 'kiva tapata' },
  // Heard as written Finnish: the written register counts, so no error.
  'clip-3.wav': { status: 'heard', heard: 'paljonko se maksaa' },
  'clip-4.wav': { status: 'heard', heard: 'moi mä on alex' },
  // The service leaned on the reference and wrote the long vowel anyway.
  'clip-5.wav': { status: 'heard', heard: 'onks teil kauramaitoo' },
}

describe('the word error harness', () => {
  it('[speak 22] gives the exact numbers on five tone clips with recorded fake answers, with no transcript', async () => {
    const clips = new Map(CLIPS.map((clip, i) => [clip.file, toneClip(0.5 + i * 0.25)]))
    const seen: { file: string; reference: string; bytes: number }[] = []
    const report = await werReport(
      CLIPS,
      (file) => Promise.resolve(clips.get(file) ?? new Uint8Array()),
      (wav, reference) => {
        const file = [...clips].find(([, bytes]) => bytes === wav)?.[0] ?? ''
        seen.push({ file, reference, bytes: wav.length })
        return Promise.resolve(HEARD[file] ?? { status: 'not_heard', heard: '' })
      },
    )
    // Each clip went through the check with its own audio and the spoken line as the reference.
    expect(seen.map((s) => [s.file, s.reference])).toEqual(CLIPS.map((clip) => [clip.file, clip.spoken]))
    expect(seen.map((s) => s.bytes)).toEqual([16_044, 24_044, 32_044, 40_044, 48_044])

    expect(
      report.perClip.map((clip) => [clip.file, clip.wordErrorRate, clip.feedbackClass, clip.agrees]),
    ).toEqual([
      ['clip-1.wav', 0, 'clear', true],
      ['clip-2.wav', 0.5, 'close', true],
      ['clip-3.wav', 0, 'clear', true],
      ['clip-4.wav', 0.25, 'close', true],
      ['clip-5.wav', 0, 'clear', false],
    ])
    expect(report.clips).toBe(5)
    expect(report.checked).toBe(5)
    expect(report.failed).toBe(0)
    // 2 word edits over 16 reference words.
    expect(report.wordErrorRate).toBe(0.125)
    expect(report.agreement).toBe(0.8)
    expect(report.lengthMistakes).toEqual({ planted: 2, caught: 1 })
    expect(report.targets).toEqual({ maxWordErrorRate: 0.25, clipsForVendorPick: 50, minAgreement: 0.85 })
    // Five clips are not the 50 the vendor pick needs, and 80 percent is under the bar.
    expect(report.meetsWordErrorTarget).toBe(false)
    expect(report.meetsAgreementBar).toBe(false)

    const printed = JSON.stringify(report) + reportLines(report, 'fake').join('\n')
    for (const answer of Object.values(HEARD)) expect(printed).not.toContain(answer.heard)
    expect(printed).not.toMatch(/tapata|kauramaitoo|paljonko/)
    expect(reportLines(report, 'fake')).toEqual([
      'Provider: fake. Clips: 5, checked 5, failed 0.',
      'Word error rate: 12.5 percent (target below 25.0 percent on 50 clips): not met.',
      'Agreement with the reviewer: 80.0 percent (bar 85.0 percent): not met.',
      'Planted length mistakes caught: 1 of 2.',
    ])
  })

  it('[speak 22] a clip the provider cannot check is counted as failed and left out of the rates', async () => {
    const report = await werReport(
      CLIPS.slice(0, 2),
      () => Promise.resolve(toneClip(0.5)),
      (_wav, reference) =>
        reference.startsWith('Kiva')
          ? Promise.reject(new Error('busy'))
          : Promise.resolve({ status: 'heard', heard: 'moi mä oon alex' }),
    )
    expect(report.failed).toBe(1)
    expect(report.checked).toBe(1)
    expect(report.wordErrorRate).toBe(0)
    expect(report.perClip[1]).toMatchObject({ failed: true, wordErrorRate: null, agrees: null })
  })

  it('[speak 22] counts word errors against the better register', () => {
    expect(wordErrors('Moi! Mä oon Alex.', 'moi mä on alex')).toEqual({ edits: 1, words: 4 })
    expect(wordErrors('Kiva tavata!', '')).toEqual({ edits: 2, words: 2 })
    expect(wordErrors('Kiva tavata!', 'kiva tavata sinut')).toEqual({ edits: 1, words: 2 })
  })

  it('[speak 22] refuses an incomplete manifest', () => {
    expect(parseManifest({ clips: CLIPS })).toHaveLength(5)
    expect(() => parseManifest({})).toThrow(/clips/)
    expect(() => parseManifest({ clips: [{ ...CLIPS[0], reviewer: 'maybe' }] })).toThrow(/Clip 1/)
    expect(() => parseManifest({ clips: [{ ...CLIPS[0], file: '../escape.wav' }] })).toThrow(/Clip 1/)
  })
})

describe('the clip folder', () => {
  const root = process.cwd()
  const git = (path: string) => {
    try {
      execFileSync('git', ['check-ignore', '-q', path], { stdio: 'ignore' })
      return true
    } catch {
      return false
    }
  }

  it('[speak 22] may be outside the repository', () => {
    const outside = mkdtempSync(join(tmpdir(), 'speech-wer-'))
    try {
      expect(clipFolderProblem(outside, root, git)).toBeNull()
    } finally {
      rmSync(outside, { recursive: true, force: true })
    }
  })

  it('[speak 22] may be a folder git ignores, and is refused anywhere else in the repository', () => {
    const ignored = join(root, 'test-results', 'speech-wer-check')
    mkdirSync(ignored, { recursive: true })
    try {
      expect(clipFolderProblem(ignored, root, git)).toBeNull()
    } finally {
      rmSync(ignored, { recursive: true, force: true })
    }
    expect(clipFolderProblem(join(root, 'content', 'checks'), root, git)).toBe('tracked_by_git')
    expect(clipFolderProblem(root, root, git)).toBe('tracked_by_git')
    expect(clipFolderProblem(join(root, 'no-such-folder-here'), root, git)).toBe('missing')
    const file = join(tmpdir(), `speech-wer-file-${String(process.pid)}.txt`)
    writeFileSync(file, 'x')
    try {
      expect(clipFolderProblem(file, root, git)).toBe('not_a_folder')
    } finally {
      rmSync(file, { force: true })
    }
  })
})
