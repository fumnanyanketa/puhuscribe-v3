import { defineConfig } from 'vitest/config'

// Unit tests run in Node. Kept separate from vite.config.ts so the Cloudflare
// plugin does not start a Worker runtime for every test run.
export default defineConfig({
  test: {
    environment: 'node',
    globals: false,
    include: [
      'src/**/*.test.ts',
      'worker/**/*.test.ts',
      'scripts/security/**/*.test.ts',
      'scripts/ci/**/*.test.ts',
      'scripts/v2-import/**/*.test.ts',
      'scripts/hooks/**/*.test.ts',
      'tests/**/*.test.ts',
    ],
  },
})
