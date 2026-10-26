// Records Azure's real answers as the fake speech provider's fixtures
// (factory/jobs/10-speaking-feedback/spec.md, "Done when" 23).
// Run only by the manual workflow "Speech fixtures":
//
//   node scripts/speech/record-fixtures.ts <folder with recorded-*.wav>
//
// Each WAV is a fixture line voiced by Azure text to speech (never a human
// voice), turned into 16 kHz mono 16 bit WAV. It goes through the speech
// provider module with the line as the reference, and Azure's answer
// replaces worker/providers/fixtures/speech/<name>.json. The answer holds no
// key and no header. The settings come from the environment; this file never
// names or prints the key.

import { readFileSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'
import { RECORDED_FIXTURES } from '../../worker/providers/fixtures/speech/index.ts'
import { mapAzureAnswer, recordAzureAnswer } from '../../worker/providers/speech-feedback.ts'

const [folder, ...rest] = process.argv.slice(2)
if (!folder || rest.length > 0) {
  console.error('Usage: node scripts/speech/record-fixtures.ts <folder with recorded-*.wav>')
  process.exit(1)
}

const today = new Date().toISOString().slice(0, 10)
for (const [name, line] of Object.entries(RECORDED_FIXTURES)) {
  const wav = new Uint8Array(readFileSync(join(folder, `${name}.wav`)))
  const answer = await recordAzureAnswer(process.env, wav, line, (input, init) => fetch(input, init))
  // The answer must be one the fake can replay.
  if (mapAzureAnswer(answer.response).status !== 'heard') {
    console.error(`Azure heard nothing in ${name}; the fixture is left as it was.`)
    process.exit(1)
  }
  const fixture = {
    about:
      `Recorded from Azure on ${today} by the manual workflow "Speech fixtures" ` +
      '(.github/workflows/speech-fixtures.yml): the line voiced by Azure text to speech (fi-FI-NooraNeural, ' +
      'a computer voice), sent through worker/providers/speech-feedback.ts with the line as the reference. ' +
      'Used only by the fake speech provider in tests.',
    source: 'recorded',
    reference: line,
    httpStatus: answer.httpStatus,
    response: answer.response,
  }
  writeFileSync(
    join('worker/providers/fixtures/speech', `${name}.json`),
    `${JSON.stringify(fixture, null, 2)}\n`,
  )
  console.log(`Recorded ${name}.`)
}
