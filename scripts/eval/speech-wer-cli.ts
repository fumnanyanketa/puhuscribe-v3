// npm run eval:speech-wer -- <folder>
// (factory/jobs/10-speaking-feedback/spec.md, "Done when" 22)
//
// Runs reviewer labelled clips through the speech provider and writes the
// word error report. The folder holds manifest.json and the WAV clips (16 kHz
// mono 16 bit). It must be outside this repository or ignored by git, so no
// clip is ever committed; any other folder is refused.
//
// The provider comes from the same settings as the Worker
// (SPEECH_FEEDBACK_PROVIDER and the Azure key, region and price tier), read
// from the environment by worker/providers/speech-feedback.ts. The key is
// never printed.
// The report goes to <folder>/wer-report.json and holds no transcript.
//
// This script only checks the folder, then runs scripts/eval/speech-wer.eval.ts
// through Vitest, which can load v2's grader as the app does.

import { execFileSync, spawnSync } from 'node:child_process'
import { resolve } from 'node:path'
import { CLIP_FOLDER_MESSAGES, clipFolderProblem } from './clip-folder.ts'

const [folder, ...rest] = process.argv.slice(2)
if (!folder || rest.length > 0) {
  console.error('Usage: npm run eval:speech-wer -- <folder with manifest.json and the clips>')
  process.exit(1)
}

const root = process.cwd()
function ignoredByGit(path: string): boolean {
  try {
    execFileSync('git', ['check-ignore', '-q', path], { stdio: 'ignore' })
    return true
  } catch {
    return false
  }
}

const problem = clipFolderProblem(folder, root, ignoredByGit)
if (problem) {
  console.error(CLIP_FOLDER_MESSAGES[problem])
  process.exit(1)
}

const run = spawnSync(
  'npx',
  ['vitest', 'run', '--config', 'vitest.eval.config.ts', '--silent=false', '--reporter=verbose'],
  {
    stdio: 'inherit',
    shell: process.platform === 'win32',
    env: { ...process.env, SPEECH_WER_FOLDER: resolve(folder) },
  },
)
process.exit(run.status ?? 1)
