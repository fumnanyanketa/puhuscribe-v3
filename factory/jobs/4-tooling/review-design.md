# Design review: 4-tooling, round 1

Scope: no screens changed, so this is a writing review of `AGENTS.md`, `docs/conventions.md`, the README additions, and the messages printed by `scripts/hooks/commit-tool.ts` and `scripts/hooks/stop-checks.ts`.

## Checked and correct

- The "Not in v3.0" list in `AGENTS.md` matches PRD section 4.1 line for line (12 items, same wording, same arrows). The extra line "no streaks" matches the PRD's "Not competing on" and `docs/scope/scope.md` line 21.
- The five principles match PRD section 3 (P1 to P5) in meaning. Nothing is added or dropped.
- No em dashes in `AGENTS.md`, `docs/conventions.md` or the README additions. No hype words found.
- `AGENTS.md` is 112 lines, in sections with bold lead words. The Conventions section points to `docs/conventions.md` instead of copying it.
- Project rules are clear to a future agent: triage has three named kinds, GA features say what the spec must answer, the checks rule says what to do when a check is wrong.

## Findings

1. **Should fix.** `AGENTS.md`, Product rules, first bullet. The five principles are one long sentence with five clauses split by semicolons. It is hard to scan and agents cannot cite "P2" as the PRD and specs do. Fix: make it five short sub bullets labelled P1 to P5, as under the "Not in v3.0" bullet.
2. **Should fix.** `AGENTS.md`, Writing rules. The list leaves out two of the owner's banned patterns: colon reveals ("Here's the thing:") and habitual groups of three. The file itself uses colon openers in places ("It is short on purpose: the detail lives..."). Fix: add both to the rule and reword the colon sentences.
3. **Should fix.** `scripts/hooks/commit-tool.ts`, `missingMessage`. Tells the person what to install but not what to do afterwards. Fix: end with "Then commit again."
4. **Should fix.** `scripts/hooks/stop-checks.ts` line 303, "Stop check could not run: Error". The agent gets no cause and no next step. Fix: add "Run npm run check:code in the worktree and report the problem in build.md."
5. **Should fix.** `scripts/hooks/stop-checks.ts` line 216, secret finding "secrets: file line N (RuleID)". It names the problem but not the action. Fix: add to the footer "If a secret was found, remove it from the file and tell the owner; never paste its value anywhere."
6. **Note.** Message style is nearly consistent (a check name, then the file, with a fix in brackets for setup and tool failures). Two differences: `setup:` and `lint:` and `format:` failures put the fix in brackets, while the gitleaks messages use a full sentence ending "with: <command>". Pick one form if the messages are touched again.
7. **Note.** `AGENTS.md` Output style says to explain a technical term the first time, but `lefthook`, `gitleaks`, `pgTAP` and `GA` appear with no explanation. A short gloss on first use would match the rule it sets. The "Checks" bullet is a long three sentence paragraph; splitting it would help scanning.
8. **Note.** "imported, not rewritten" (What this project is) is a mild "X, not Y" shape; "v2's proven engines are imported unchanged" says the same.
9. **Note.** `AGENTS.md` is 18 lessons long and will grow. Consider moving older lessons to a separate file once it passes about 150 lines.

No must fix findings.

Result: pass
