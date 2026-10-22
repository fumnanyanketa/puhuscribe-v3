---
name: sync
description: >
  The librarian. Runs after a feature lands and makes the paperwork match
  reality again: ticks verified plan boxes, advances decision record status
  lines, adds newly learned rules to AGENTS.md, and flags anything the change
  made outdated. Use this at the close of every feature (step 6.6), after
  merges, and whenever the user says "tidy the docs", "update the plan", or
  "sync". If the docs and the code disagree, this skill is the referee.
---

# /sync

The librarian. Docs as memory only works if something keeps the docs true.
This is that something. Tiny surgical edits, every one reported.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## When to run

- Step 6.6 of every feature, right before the fresh session.
- After any merge that changed what is true.

## When NOT to run

- Writing new plans (that is /scope), new decisions (/architect), or prose
  for humans (/document).

## Pre-flight

1. Read AGENTS.md, docs/plan.md, and the records touched by this feature.
2. Read the actual evidence: the diff, docs/evidence/ for this feature, the
   test results. Sync moves nothing without proof.

## The boundaries table (the heart of this skill)

MAY EDIT, with evidence:
- Plan rows: status to done ONLY when verify evidence exists, tests are
  green, and (for heavy) the human approved line is present.
- Decision record STATUS LINES only: In Progress to Accepted when shipped
  and verified; mark Superseded when a newer record replaces one.
- AGENTS.md: ADD newly learned conventions and rules (additive only).

MUST ONLY FLAG, never edit:
- Decision record CONTENT that reality has made stale (route to /architect).
- Undocumented areas of the codebase discovered along the way (/audit).
- Human written prose anywhere.
- UI consistency questions (that is /canvas drift, which runs beside this
  skill).

## The work

1. Walk the feature's plan row against the evidence. Tick what is proven.
2. Advance the decision record status line if the criteria above are met.
3. Ask the user: did the AI do anything this feature you never want
   repeated? If yes, add the rule to AGENTS.md now, while it is fresh.
4. If dependencies changed, note the new tools so future sessions know they
   exist.
5. Produce the sync report: EVERY edit made, listed as before and after,
   plus every flag raised and which skill owns it. No silent changes, ever.

## Team safety

Re-read every file immediately before editing it. Single line surgical
edits. When evidence is ambiguous, flag instead of ticking.

## Hand-off

Show the sync report. Remind the user to commit (their save point). Then
the standing instruction: start a completely fresh session for the next
feature. Everything important is now in files; the old session is
disposable.
