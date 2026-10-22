---
name: check
description: >
  Prove that built work is actually correct. Three modes: verify (run the
  real app against the acceptance criteria and record evidence), review (a
  DIFFERENT AI model reads the code and reports problems by severity), and
  eval (score an AI powered feature against its golden set). Use this
  whenever a feature was just built, when the user says "check it", "does it
  work", "review this code", "prove it", "test the AI feature", or before
  anything is marked done. Never mark work done without this skill.
---

# /check

The prover. Runtime proof, fresh eyes review, and AI feature scoring.
This skill never edits code. It only judges and records.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## Mode selection

Read EXACTLY ONE mode file, then follow it. Do not read the others.

- The feature was just built and needs runtime proof -> modes/verify.md
- The code needs a second opinion -> modes/review.md
- The feature is itself powered by AI and needs grading -> modes/eval.md

If the user is ambiguous, verify comes first in the pipeline; recommend it.

## When NOT to run

- Writing tests (that is /test).
- Fixing anything found (route findings to /develop or /debug).

## Pre-flight (all modes)

1. Read AGENTS.md.
2. Read the feature's decision record; the numbered acceptance criteria are
   the yardstick for every mode.

## Artifact ownership (all modes)

MAY write: docs/evidence/ (verify), docs/reviews/ (review, eval reports).
MUST NEVER touch: app code, tests, plan rows, decision content.
Findings are reported and routed, never fixed in place.

## Hand-off (all modes)

Report pass/fail per criterion or finding count by severity. Name the next
skill (/test after verify, /develop or /debug after failed findings,
/document when everything is green). Suggest a fresh session.
