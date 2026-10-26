import { readFileSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'
import { expect, it } from 'vitest'
import { speechProvider } from '../../worker/providers/speech-feedback.ts'
import { parseManifest, reportLines, werReport } from './speech-wer.ts'

// The word error run itself, started by scripts/eval/speech-wer-cli.ts
// (npm run eval:speech-wer -- <folder>), which has already checked that the
// folder is outside the repository or ignored by git. Job
// 10-speaking-feedback, "Done when" 22. Nothing here prints a transcript or a key.

const folder = process.env.SPEECH_WER_FOLDER ?? ''

it('[speak 22] runs every clip in the folder through the speech provider and writes the report', async () => {
  expect(folder, 'Start this through npm run eval:speech-wer -- <folder>.').not.toBe('')
  const provider = speechProvider(process.env, (input, init) => fetch(input, init))
  expect(provider, 'The speech provider is not set up (key, EU region and price tier).').not.toBeNull()
  if (!provider) return
  const clips = parseManifest(JSON.parse(readFileSync(join(folder, 'manifest.json'), 'utf8')))
  const report = await werReport(
    clips,
    (file) => Promise.resolve(new Uint8Array(readFileSync(join(folder, file)))),
    (wav, reference) => provider.check(wav, reference, null),
  )
  writeFileSync(
    join(folder, 'wer-report.json'),
    `${JSON.stringify({ provider: provider.name, ...report }, null, 2)}\n`,
  )
  console.log(
    [...reportLines(report, provider.name), `Report: ${join(folder, 'wer-report.json')}`].join('\n'),
  )
}, 600_000)
