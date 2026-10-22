---
name: nightshift
description: >
  ADVANCED, adopt late. A bounded autonomous loop: give the AI one objective
  and a hard stop condition (a spending cap, an iteration cap, or "until no
  problems remain"), and it cycles through build, verify, and debug
  unattended, leaving evidence for morning review. Use this only when the
  user explicitly asks for an overnight or unattended run AND /check verify
  evidence has been trusted for weeks. Otherwise decline and say why.
---

# /nightshift

The overnight worker. Safe only because every cycle leaves evidence a human
inspects in the morning. Autonomy without proof is just hope running in a
loop.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## The gate (check before anything)

1. The single agent loop has been reliable for weeks, and the user actually
   reads the evidence /check verify produces.
2. The objective is VERIFIABLE: success can be checked mechanically, not
   vibes ("all golden set items pass", "the app completes the signup flow
   with these 10 inputs", "no lint or type errors remain").
3. A hard stop condition exists. No stop condition, no run.

## Setting up a run

1. OBJECTIVE: one sentence, verifiable. Example: "act like a first time
   user, complete the whole main flow, find and fix the first problem,
   repeat."
2. STOP CONDITION, at least one, all recorded before starting:
   an iteration cap (for example 10 cycles), a budget cap (tokens or
   money), or "until the objective's check passes cleanly twice in a row".
3. BOUNDARIES: the run works on its own branch, never on main. It may not
   change decision records, AGENTS.md, or the plan. It may not install new
   libraries. Anything requiring a decision gets logged and skipped, not
   invented (the /develop gate stays on even at 3am).

## Each cycle

1. Pick the next problem toward the objective.
2. Run the standard mini loop: build the smallest change, /check verify the
   affected path with evidence saved, run the tests.
3. Log the cycle: what was attempted, what the evidence shows, tokens or
   time spent.
4. Check the stop condition. Stop means stop.

## The morning after

Produce the night report: cycles run, problems fixed with their evidence
links, problems logged but skipped (with why), budget used, and the exact
branch name. The user reviews the evidence and decides what merges. Nothing
from the night touches main without the daytime review ritual (/check
review, then merge).

## Artifact ownership

MAY write: app code on its own branch, evidence, the night log.
MUST NEVER touch: main, decision records, AGENTS.md, docs/plan.md.
