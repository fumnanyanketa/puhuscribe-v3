---
name: test
description: >
  Write the automated tests for what was just built, each labeled with the
  acceptance criterion it protects. Use this after /check verify passes,
  whenever the user says "write tests", "lock this in", "protect this
  feature", or when a bug fix needs a regression test so it can never
  silently return. The scope is always the recent uncommitted changes unless
  the user names something else.
---

# /test

The safety net writer. Turns a working feature into a protected one, so any
future change that breaks it makes the tests scream immediately.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## When to run

- Right after /check verify passes for a feature.
- After /debug fixes a bug (the regression test that pins the fix).

## When NOT to run

- To prove the feature works in the first place (that is /check verify).
- To fix failing behavior (that is /develop or /debug).

## Pre-flight

1. Read AGENTS.md.
2. Determine scope: the uncommitted changes in the working tree. The diff IS
   the scope; do not ask the user what to test unless the tree is clean.
3. Read the feature's decision record for the numbered acceptance criteria.
4. Read test-preferences.md in docs/ if it exists (framework and style
   choices saved from earlier runs). If it does not exist, recommend a
   framework once, record the choice there, and never ask again.

## Asks vs acts

- INFER what kind of test each changed file needs from what it is:
  pure logic gets unit tests, screens and flows get end to end tests (tests
  that drive the app like a user), server endpoints get request tests.
- ASK nothing that the diff, the record, or the preferences file answers.
- RECOMMEND the smallest test set that covers every automatable criterion.

## The work

1. For each changed file, write tests using the per class strategy above.
   Weight end to end tests for pages and flows, unit tests for pure logic.
2. TRACEABILITY: every test carries a comment naming the criterion it
   protects, for example: covers AC-3. Every automatable criterion must be
   covered by at least one test.
3. Criteria that cannot be automated (a real email arriving in a real
   inbox) go on an honest manual checklist in docs/evidence/feature-name/
   manual-checks.md. Never fake them with a test that proves nothing.
4. Run the whole test suite, not just the new tests. Everything green.
5. STUB FIRST option (open decision D1, default off): if the user has turned
   on stub first for heavy features, this skill runs BEFORE /develop
   instead: write the tests from the acceptance criteria, watch them fail,
   and hand /develop the failing suite as the target.

## Hard rules

- Never modify application code to make a test pass. If the code is wrong,
  route to /develop or /debug with the failing test attached.
- Never write coverage for coverage's sake. A test that cannot fail for a
  real reason is noise.

## Artifact ownership

MAY write: test files, docs/test-preferences.md, the manual checklist.
MUST NEVER touch: application code, evidence, reviews, plan rows.

## Hand-off

Report tests written, criteria covered, criteria deferred to manual. Name
the next skill: /check review. Suggest a fresh session.
