import { readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'

// Labels in brackets are the "Done when" statement numbers from
// factory/jobs/4-tooling/spec.md that each test protects.
//
// The owner chose option B for call 1 (factory/jobs/4-tooling/summary.md,
// 20 October 2026): run the stop check only when the factory builder agent
// stops. .claude/settings.json must hold exactly the spec's JSON for option B,
// with the progress log hook from job 2 unchanged.

const OPTION_B = {
  hooks: {
    Stop: [
      {
        hooks: [{ type: 'command', command: 'node "$CLAUDE_PROJECT_DIR/recording/log-turn.mjs"' }],
      },
    ],
    SubagentStop: [
      {
        matcher: 'factory-builder',
        hooks: [
          {
            type: 'command',
            command: 'node "$CLAUDE_PROJECT_DIR/scripts/hooks/stop-checks.ts" worktrees',
            timeout: 120,
          },
        ],
      },
    ],
  },
}

describe('Claude Code settings', () => {
  const settings: unknown = JSON.parse(readFileSync('.claude/settings.json', 'utf8'))

  it('[tooling 16] hold exactly the JSON for option B', () => {
    expect(settings).toStrictEqual(OPTION_B)
  })

  it('[tooling 16] keep the progress log as the only Stop hook, so no session other than the builder is checked', () => {
    expect((settings as typeof OPTION_B).hooks.Stop).toHaveLength(1)
    expect(JSON.stringify((settings as typeof OPTION_B).hooks.Stop)).not.toContain('stop-checks')
  })
})

describe('lefthook cannot change Claude Code settings or fetch hook commands', () => {
  // lefthook's `ai` setting writes .claude/settings.json during `lefthook
  // install` (so on every npm ci), before any test sees the change. `remotes`
  // and `extends` pull more hook commands from another repository or file.
  const lefthook = readFileSync('lefthook.yml', 'utf8').replace(/\r\n/g, '\n')
  const FORBIDDEN = ['ai', 'remotes', 'extends']

  // Top-level keys only: a line that starts with the key, quoted or not.
  function hasTopLevelKey(text: string, key: string): boolean {
    return new RegExp(`^['"]?${key}['"]?[ \\t]*:`, 'm').test(text)
  }

  it.each(FORBIDDEN)('[tooling 16] lefthook.yml has no top-level "%s" setting', (key) => {
    expect(hasTopLevelKey(lefthook, key)).toBe(false)
  })

  it.each(FORBIDDEN)('[tooling 16] the check really catches a planted "%s" setting', (key) => {
    expect(hasTopLevelKey(`${lefthook}\n${key}:\n  x: true\n`, key)).toBe(true)
    expect(hasTopLevelKey(`${lefthook}\n"${key}" : []\n`, key)).toBe(true)
  })
})
