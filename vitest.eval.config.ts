import { defineConfig } from 'vitest/config'

// Only for npm run eval:speech-wer (scripts/eval/speech-wer-cli.ts, job
// 10-speaking-feedback). It runs the word error harness on a folder of
// reviewer labelled clips, with the real speech provider. npm test never
// includes it.
export default defineConfig({
  test: {
    environment: 'node',
    globals: false,
    include: ['scripts/eval/**/*.eval.ts'],
  },
})
