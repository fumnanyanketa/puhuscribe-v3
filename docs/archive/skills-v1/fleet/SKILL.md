---
name: fleet
description: >
  ADVANCED, adopt late. Run several AI builders in parallel, each in its own
  isolated copy of the repository (a git worktree) so they cannot trample
  each other, coordinated like a small crew. Use this only when the user
  explicitly asks for parallel agents, multiple features at once, or names
  fleet, AND the single agent build loop has been boringly reliable for
  weeks. If that condition is not met, say so and decline politely.
---

# /fleet

The crew manager. Parallelism multiplies whatever already exists: solid
discipline becomes solid throughput, chaos becomes more chaos. Earn it
first.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## The gate (check before anything)

All three must be true, or stop and say why:
1. The single agent loop (architect, develop, verify, test, review, sync)
   has run reliably for weeks without babysitting.
2. Every candidate feature has its own decision record already.
3. The plan rows chosen for parallel work do not touch the same files.

## Why this works at all

State lives in files (the plan, the records, AGENTS.md), so every parallel
worker reads the same truth. A git worktree gives each worker a full,
isolated copy of the project on its own branch; nobody edits anybody
else's files.

## The work

1. DECOMPOSE: with the user, pick 2 or 3 plan rows that are independent
   (different screens, different folders, no shared files). Reject overlaps.
2. ISOLATE: create one worktree per row, each on its own branch named for
   the feature.
3. BRIEF: each worker session starts the same way: read AGENTS.md, read
   your one decision record, run the standard loop (develop, verify, test)
   inside your worktree only.
4. COLLISION RULES for shared docs: workers never edit docs/plan.md or
   AGENTS.md; they flag. Only the coordinating session (this one) runs
   /sync, one feature at a time, after each merge.
5. MERGE ONE AT A TIME: bring branches back serially, running /check review
   and the full test suite after each merge, never in a batch.
6. CLEAN UP: remove worktrees when their branch has merged.

## Artifact ownership

MAY manage: worktrees, branches, the coordination notes.
MUST NEVER: let two workers own the same file, or let any worker write the
shared docs.

## Hand-off

Report per worker status, merged branches, and what /sync recorded. Then
back to the ordinary loop; fleet is a tool for bursts, not a lifestyle.
