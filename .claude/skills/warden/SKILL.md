---
name: warden
description: >
  The security sweep. Scans for leaked secret keys, vulnerable dependencies,
  and risky paths (logins, payments, personal data), and reports findings by
  severity. Use this before every release, after heavy weight features,
  whenever the user says "security check", "scan for secrets", "is this
  safe", and on a monthly maintenance cadence even when nobody asks. Also
  triggered by /check review when it smells a security problem.
---

# /warden

The security guard. Finds the problems that turn into headlines, before
users do. Never edits code; reports and routes.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## When to run

- Before every release (called by /liftoff).
- After every heavy weight feature (alongside /check review).
- Monthly, as maintenance, even when nothing changed.

## When NOT to run

- Design time security thinking (the three threat model questions) lives
  inside /architect, not here. This skill checks the built thing.
- Fixing what it finds (route to /develop or /debug with the finding).

## Pre-flight

1. Read AGENTS.md, especially the secret rules.
2. Read the specs in docs/specs/ of recently shipped GA tagged features,
   including their security model and threat model answers. The sweep checks that reality matches them.

## The work

1. SECRETS: scan the code AND the entire git history for keys, passwords,
   and tokens. A secret that was committed once and deleted is still leaked;
   flag it for rotation (getting a new key and killing the old one).
2. DEPENDENCIES: run the ecosystem's audit tool (for example npm audit) for
   known vulnerabilities in the libraries the project uses. List each with
   its severity and whether an upgrade exists.
3. RISKY PATHS: read the code around logins, payments, personal data, file
   uploads, and anywhere external or user supplied content enters. Check
   the standing rule: all scraped and user supplied content is treated as
   hostile input. Check that secrets are only used server side.
4. THREAT MODEL RECONCILIATION: for each GA tagged feature, compare what was
   promised in its threat model answers against what the code does.
5. Write the report to docs/reviews/security-YYYY-MM-DD.md: findings ranked
   Critical / High / Medium / Low, each with file, line, why it matters,
   and the one line fix direction.
6. Critical findings block release. Say so plainly.

## Deterministic layer note

The free mechanical tools (a secret scanner, the dependency audit, the
linter) run first and always. AI judgment sits on top of them, never
instead of them. (Open decision D2: turning these into automatic pre commit
tripwires, called hooks, is the stronger future version.)

## Artifact ownership

MAY write: docs/reviews/security-*.md.
MUST NEVER touch: app code, specs, the scope.

## Hand-off

Report counts by severity and whether release is blocked. Route Critical
and High to /develop or /debug now; Medium and Low become plan rows. Name
the next skill. Suggest a fresh session.
