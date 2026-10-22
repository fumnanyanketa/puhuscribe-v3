import thresholds from '../../content/checks/speech-thresholds.json' with { type: 'json' }
import { normalizeAnswer } from '../../src/lib/grade.ts'
import { classifySpeech, type FeedbackClass, type HeardAnswer } from '../../src/lib/speech-feedback.ts'

// The word error harness (factory/jobs/10-speaking-feedback/spec.md, "Done
// when" 22). It runs reviewer labelled clips through the speech provider and
// reports the word error rate per clip and overall, how often the feedback
// agrees with the native reviewer, and how many planted length mistakes the
// feedback caught. The report never holds what the service heard.
// The 50 clip run that decides the vendor is risk test 3, not this job.

export interface ClipEntry {
  /** The WAV file's name inside the clip folder. */
  file: string
  spoken: string
  written: string
  /** The native reviewer's label: said correctly, or not. */
  reviewer: 'correct' | 'not_correct'
  /** Where it was not correct, in the reviewer's words. */
  where?: string
  /** True when the clip has a planted length mistake (such as tuli for tuuli). */
  lengthMistakePlanted: boolean
}

export interface ClipResult {
  file: string
  wordErrorRate: number | null
  feedbackClass: FeedbackClass | null
  reviewer: ClipEntry['reviewer']
  agrees: boolean | null
  lengthMistakePlanted: boolean
  /** For a planted length mistake: whether the feedback said anything but clear. */
  lengthMistakeCaught: boolean | null
  /** True when the provider could not check the clip. */
  failed: boolean
}

export interface WerReport {
  clips: number
  checked: number
  failed: number
  wordErrorRate: number | null
  agreement: number | null
  lengthMistakes: { planted: number; caught: number }
  targets: { maxWordErrorRate: number; clipsForVendorPick: number; minAgreement: number }
  meetsWordErrorTarget: boolean
  meetsAgreementBar: boolean
  perClip: ClipResult[]
}

function words(text: string): string[] {
  return normalizeAnswer(text).split(' ').filter(Boolean)
}

/** Word level edits between the reference and what was heard, and the reference's length in words. */
export function wordErrors(reference: string, heard: string): { edits: number; words: number } {
  const ref = words(reference)
  const hyp = words(heard)
  let previous = Array.from({ length: hyp.length + 1 }, (_, j) => j)
  for (let i = 1; i <= ref.length; i += 1) {
    const current = [i]
    for (let j = 1; j <= hyp.length; j += 1) {
      const same = ref[i - 1] === hyp[j - 1] ? 0 : 1
      current[j] = Math.min((current[j - 1] ?? 0) + 1, (previous[j] ?? 0) + 1, (previous[j - 1] ?? 0) + same)
    }
    previous = current
  }
  return { edits: previous[hyp.length] ?? 0, words: ref.length }
}

function rounded(value: number): number {
  return Math.round(value * 10_000) / 10_000
}

/** Checks a manifest's shape and returns its clips. Throws with a plain message when it is wrong. */
export function parseManifest(value: unknown): ClipEntry[] {
  const clips = (value as { clips?: unknown } | null)?.clips
  if (!Array.isArray(clips) || clips.length === 0)
    throw new Error('The manifest needs a non-empty "clips" list.')
  return clips.map((item: unknown, index) => {
    const clip = item as Partial<ClipEntry> | null
    const ok =
      clip !== null &&
      typeof clip.file === 'string' &&
      /^[\w.-]+\.wav$/i.test(clip.file) &&
      typeof clip.spoken === 'string' &&
      typeof clip.written === 'string' &&
      (clip.reviewer === 'correct' || clip.reviewer === 'not_correct') &&
      typeof clip.lengthMistakePlanted === 'boolean'
    if (!ok) throw new Error(`Clip ${String(index + 1)} in the manifest is not complete.`)
    return clip as ClipEntry
  })
}

export async function werReport(
  clips: readonly ClipEntry[],
  readClip: (file: string) => Promise<Uint8Array>,
  check: (wav: Uint8Array, reference: string) => Promise<HeardAnswer>,
): Promise<WerReport> {
  const perClip: ClipResult[] = []
  let edits = 0
  let total = 0
  for (const clip of clips) {
    let answer: HeardAnswer | null
    try {
      answer = await check(await readClip(clip.file), clip.spoken)
    } catch {
      answer = null
    }
    if (!answer) {
      perClip.push({
        file: clip.file,
        wordErrorRate: null,
        feedbackClass: null,
        reviewer: clip.reviewer,
        agrees: null,
        lengthMistakePlanted: clip.lengthMistakePlanted,
        lengthMistakeCaught: null,
        failed: true,
      })
      continue
    }
    // The better of the two registers counts, as in the feedback rules.
    const heard = answer.status === 'heard' ? answer.heard : ''
    const spoken = wordErrors(clip.spoken, heard)
    const written = wordErrors(clip.written, heard)
    const rate = (e: { edits: number; words: number }) => e.edits / Math.max(e.words, 1)
    const errors = rate(written) < rate(spoken) ? written : spoken
    edits += errors.edits
    total += errors.words
    const feedback = classifySpeech({ spoken: clip.spoken, written: clip.written }, answer)
    const saidCorrectly = feedback.feedbackClass === 'clear'
    perClip.push({
      file: clip.file,
      wordErrorRate: rounded(errors.edits / Math.max(errors.words, 1)),
      feedbackClass: feedback.feedbackClass,
      reviewer: clip.reviewer,
      agrees: saidCorrectly === (clip.reviewer === 'correct'),
      lengthMistakePlanted: clip.lengthMistakePlanted,
      lengthMistakeCaught: clip.lengthMistakePlanted ? !saidCorrectly : null,
      failed: false,
    })
  }
  const checked = perClip.filter((clip) => !clip.failed)
  const agreeing = checked.filter((clip) => clip.agrees).length
  const planted = checked.filter((clip) => clip.lengthMistakePlanted)
  const wordErrorRate = total > 0 ? rounded(edits / total) : null
  const agreement = checked.length > 0 ? rounded(agreeing / checked.length) : null
  const targets = {
    maxWordErrorRate: thresholds.wordErrorRate.maxWordErrorRate,
    clipsForVendorPick: thresholds.wordErrorRate.clips,
    minAgreement: thresholds.reviewerAgreement.minAgreement,
  }
  return {
    clips: clips.length,
    checked: checked.length,
    failed: perClip.length - checked.length,
    wordErrorRate,
    agreement,
    lengthMistakes: {
      planted: planted.length,
      caught: planted.filter((clip) => clip.lengthMistakeCaught).length,
    },
    targets,
    meetsWordErrorTarget:
      wordErrorRate !== null &&
      wordErrorRate < targets.maxWordErrorRate &&
      checked.length >= targets.clipsForVendorPick,
    meetsAgreementBar: agreement !== null && agreement >= targets.minAgreement,
    perClip,
  }
}

/** The report as a few plain lines for the terminal. */
export function reportLines(report: WerReport, provider: string): string[] {
  const percent = (value: number | null) => (value === null ? 'none' : `${(value * 100).toFixed(1)} percent`)
  return [
    `Provider: ${provider}. Clips: ${String(report.clips)}, checked ${String(report.checked)}, failed ${String(report.failed)}.`,
    `Word error rate: ${percent(report.wordErrorRate)} (target below ${percent(report.targets.maxWordErrorRate)} on ${String(report.targets.clipsForVendorPick)} clips): ${report.meetsWordErrorTarget ? 'met' : 'not met'}.`,
    `Agreement with the reviewer: ${percent(report.agreement)} (bar ${percent(report.targets.minAgreement)}): ${report.meetsAgreementBar ? 'met' : 'not met'}.`,
    `Planted length mistakes caught: ${String(report.lengthMistakes.caught)} of ${String(report.lengthMistakes.planted)}.`,
  ]
}
