---
name: debug
description: >
  The detective. The ritual for "it broke": triage first (real bug, polluted
  session, or wrong earlier decision), then a disciplined investigation for
  real bugs: reproduce, prove the cause, smallest fix, regression test. Use
  this whenever anything is broken, failing, weird, "worked yesterday",
  crashing, or the user is frustrated that fixes keep not fixing. Never just
  start patching without this skill's triage.
---

# /debug

The detective. "It's broken, fix it" is how a person and an AI spiral
together for an afternoon. This skill replaces the spiral with a ritual.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## Step 0: TRIAGE (always first, before any code is touched)

Broken situations come in three kinds with three different cures. Decide
which one this is, out loud:

1. A REAL BUG: something specific misbehaves, repeatably.
   Cure: the investigation loop below.
2. A POLLUTED SESSION: the AI contradicts itself, circles, forgets, fixes
   the same thing repeatedly.
   Cure: do not argue with it. Close the session, open a fresh one, let it
   read the files. Two minutes, problem usually gone. This skill's job in
   that case is simply to say so and stop.
3. A WRONG EARLIER DECISION: the bug keeps returning in new costumes.
   Cure: do not patch the symptom. Route to /architect to update or
   supersede the decision record, then rebuild on the corrected decision.

## The investigation loop (real bugs only)

1. REPRODUCE FIRST, as a real user would hit it, end to end. A bug that
   cannot be made to happen on demand cannot be proven fixed. Record the
   exact reproduction steps.
2. LOCALIZE: narrow where it lives. Halve the search space: does it happen
   on this screen but not that one, with this input but not that one, in
   this version but not the previous one (git history is a search tool).
3. ONE HYPOTHESIS AT A TIME: state a single falsifiable theory ("the error
   shows because the response is empty"), design the smallest experiment
   that would prove it wrong, run it. If wrong, next theory. Never shotgun
   five changes at once.
4. PROVE THE ROOT CAUSE before fixing. Never accept a fix nobody can
   explain: a fix without a proven cause is a coincidence wearing a
   costume.
5. SMALLEST FIX at the root. No refactors riding along, no cleanups, no
   improvements. One bug, one fix.
6. SIBLING SWEEP: search the codebase for the same mistake pattern
   elsewhere; the same hand usually made it twice.
7. VERIFY: run the reproduction steps and watch the bug not happen. Then
   run the full test suite.
8. Hand /test the reproduction so it becomes a regression test: this exact
   bug can now never silently return.

## Hard rules

- Never fix on a hunch. Never say "try this and see".
- If the proven cause is a flawed decision, stop and route to /architect.
- Explain the cause to the user in plain words. Their understanding
  compounds; a silent fix teaches nothing.

## Artifact ownership

MAY write: the minimal fix in app code, the reproduction notes.
MUST NEVER touch: decision content, plan rows (flag to /sync), AGENTS.md.

## Hand-off

Report the proven cause, the fix, the sibling sweep result. Name the next
skill: /test for the regression test, then /check verify. Suggest a fresh
session.
