---
name: scope
description: >
  Create and maintain docs/plan.md, the living product plan. Use this whenever
  the user describes a product idea, asks "what should we build first", says
  "plan this app", "add a feature to the plan", "where was I", "what is next",
  or returns after a break. Also run it bare after features ship to reconcile
  the plan with reality. Any request about ordering, priorities, or project
  status belongs here, even if the user never says the word plan.
---

# /scope

The planner. Turns an idea into a living plan and keeps that plan honest as
the project moves.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## When to run

- PLAN: a new idea needs its first docs/plan.md.
- REPLAN: run bare, anytime. Read the plan, reconcile it against repo
  evidence (and production evidence if available), and answer "here is where
  you are, here is what is next."
- ADD: enroll one new feature, bug, or debt item as a row.

Infer which of the three the user means. Do not ask them to pick a mode.

## When NOT to run

- Choosing technology or design (that is /architect). The plan says "users
  can log in", never "use Google login".
- Marking work done without proof (only evidence from /check verify and
  passing tests move a row to done).

## Pre-flight

1. Read AGENTS.md.
2. Read docs/plan.md if it exists.
3. For REPLAN, also skim recent commit history and docs/evidence/ for proof
   of what actually shipped. If production analytics or error summaries are
   available in docs/, read those too and let real usage reshape priorities.

## Asks vs acts

- INFER feature candidates from the idea, the code, and past conversation.
- ASK only for what the user alone knows: priorities, risk appetite, the
  success line ("I will know this worked when ___").
- RECOMMEND a build order with a one line reason, marked "recommended".

## The work

1. Every feature becomes a table row with exactly these fields:
   - Status: planned, in progress, or done.
   - Weight: light (small, low risk, minimal checking), medium (standard
     process), heavy (money, logins, personal data; every check plus the
     user's personal written sign off).
   - Done when: one line saying how we will know this feature works.
2. Debt items and recurring maintenance get rows too. They compete for
   priority visibly instead of hiding in someone's memory.
3. Features that imply an unmade technical decision get a marker:
   "Needs decision: yes". The plan never makes the decision.
4. On REPLAN, tick only what evidence supports, surface stalled rows, and
   propose the next one to three rows to tackle, with reasons.
5. Keep the plan short enough to read in two minutes. It is a map, not a
   novel.

## Artifact ownership

MAY write: docs/plan.md.
MUST NEVER touch: AGENTS.md, docs/decisions/ content, app code, evidence.
Flags anything wrong elsewhere and names the owning skill.

## Team safety

Re-read plan.md immediately before editing; others may have changed it.
Append new rows with the next free number. Never renumber existing rows.
Smallest surgical edits. When unsure, flag.

## Hand-off

Report rows added or changed and the recommended next row. Name the next
skill (/architect for the top row if it needs decisions, /develop if its
decision record already exists). Suggest a fresh session if this one is long.
