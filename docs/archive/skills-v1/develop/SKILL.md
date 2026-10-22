---
name: develop
description: >
  Build one feature from its decision record, inside the rules of AGENTS.md.
  Use this whenever the user says "build", "implement", "add the screen",
  "wire up", "create the feature", or names a plan row to work on. Also use
  it for the one time project scaffold. If the user asks to build something
  that has no decision record, still start here: this skill's first move is
  the gate that decides whether building is allowed yet.
---

# /develop

The builder. Writes the actual code, one feature at a time, and refuses to
invent decisions the user never made.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## When to run

- A plan row with a decision record is ready to build.
- The one time scaffold: creating the empty project skeleton from the stack
  record (this is the single exception that needs no feature record).

## When NOT to run

- The project does not exist yet and this is not the scaffold task.
- The gate below fails.

## Step 0: THE GATE (run before anything else)

Ask one question about the task: "To build this, would I have to invent
something the user has not decided?" A provider, a data model, a screen's
layout, a feature's behavior, a new library.

If YES: STOP. Do not build. Offer three options and recommend the first:
1. Architect it first (recommended): route to /architect now.
2. Not needed: the user says the choice truly does not matter; note that in
   the report and proceed.
3. Skip for now: build a placeholder and mark the plan row "Needs decision".

For UI work, the gate also checks design: if no locked design system exists
in design/, route to /canvas design before building screens.

## Pre-flight

1. Read AGENTS.md in full and follow it strictly.
2. Read the feature's decision record, especially the numbered acceptance
   criteria. They are the contract.
3. Read the relevant plan row. Set its status to "in progress".

## Asks vs acts

- INFER implementation details the record and codebase already settle.
- ASK only when the record is silent on something that matters (then the
  gate applies: that silence may mean routing back to /architect).
- RECOMMEND the smallest implementation that satisfies the criteria.

## The work

1. Break the feature into small tasks. One task at a time, never three.
2. For each task, hold the four part discipline internally:
   anchor (AGENTS.md rules), task (one thing), constraints (protect what
   exists: do not change existing screens, do not refactor unrelated code,
   do not add unrequested features, do not install libraries without
   asking), reference (the design image or the decision record).
3. Follow existing patterns in the codebase. Readable over clever.
   Smallest useful version first. Refactor only when repetition appears.
4. Never put secret keys in client code.
5. After each task: run the app path you changed, then run the linter (the
   automatic code style checker) and the type checker. Fix all errors
   before calling the task finished.
6. Advance the plan row only to "in progress". NEVER mark a row done; done
   requires /check verify evidence and passing tests.

## Artifact ownership

MAY write: application code, configuration the feature requires, the status
field of this feature's plan row (to "in progress" only), the Status line of
this feature's decision record (to "In Progress" only).
MUST NEVER touch: decision record content, AGENTS.md, other plan rows,
evidence, reviews.
Flags design system violations to /canvas drift and record conflicts to
/architect.

## Team safety

Pull or fetch before starting. Small commits are the user's save points;
if AGENTS.md contains the commit rule, commit after the user confirms each
verified step. Never rewrite files wholesale to change one line.

## Hand-off

Report what was built, which acceptance criteria it targets, and anything
flagged. Name the next skill: /check verify. Suggest a fresh session for
verification; the code and the record carry everything.
