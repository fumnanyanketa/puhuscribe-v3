// Starts one of the commit check's tools that npm does not install: gitleaks
// or ruff (see lefthook.yml). If the tool is not installed, the commit is
// refused with one line naming the free install command, so a missing tool
// never lets a commit through unchecked.
// Spec: factory/jobs/4-tooling/spec.md, "Done when" 9 and 13.
//
// Usage: node scripts/hooks/commit-tool.ts <gitleaks|ruff> [arguments for the tool]
import { spawnSync } from 'node:child_process'

export const INSTALL = {
  gitleaks: 'winget install --id Gitleaks.Gitleaks -e',
  ruff: 'python -m pip install --user -r scripts/requirements-dev.txt',
} as const

export type Tool = keyof typeof INSTALL

// Ways to start each tool, tried in order. pip's --user install puts ruff in a
// folder that is often not on PATH, so ruff is also tried as a Python module.
const STARTS: Record<Tool, string[][]> = {
  gitleaks: [['gitleaks']],
  ruff: [['ruff'], ['python', '-m', 'ruff'], ['python3', '-m', 'ruff']],
}

export function isTool(name: string | undefined): name is Tool {
  return name !== undefined && Object.hasOwn(INSTALL, name)
}

export function findTool(tool: Tool, env: NodeJS.ProcessEnv = process.env): string[] | undefined {
  return STARTS[tool].find(([command = '', ...rest]) => {
    const probe = spawnSync(command, [...rest, '--version'], { env, stdio: 'ignore', windowsHide: true })
    return probe.status === 0
  })
}

// The exit code lefthook.yml asks gitleaks to use when it finds a secret.
export const LEAKS_FOUND = 3
export const SECRET_FOUND_ADVICE =
  'gitleaks found a secret in the staged changes, so this commit is refused. Remove it, tell the owner, and never paste its value anywhere. Then commit again.'

export function missingMessage(tool: Tool): string {
  return `${tool} is not installed, so this commit is refused. Install it once (free) with: ${INSTALL[tool]}. Then commit again.`
}

export function main(args: string[], env: NodeJS.ProcessEnv = process.env): number {
  const [tool, ...toolArgs] = args
  if (!isTool(tool)) {
    console.error(`Usage: node scripts/hooks/commit-tool.ts <${Object.keys(INSTALL).join('|')}> [arguments]`)
    return 2
  }
  const start = findTool(tool, env)
  if (!start) {
    console.error(missingMessage(tool))
    return 1
  }
  const [command = '', ...prefix] = start
  const run = spawnSync(command, [...prefix, ...toolArgs], { env, stdio: 'inherit', windowsHide: true })
  // Only a real finding gets the secret advice: lefthook.yml runs gitleaks
  // with --exit-code 3, so its other failures (exit 1) are not mistaken for one.
  if (tool === 'gitleaks' && run.status === LEAKS_FOUND) {
    console.error(SECRET_FOUND_ADVICE)
    return 1
  }
  return run.status ?? 1
}

if (import.meta.main) process.exit(main(process.argv.slice(2)))
