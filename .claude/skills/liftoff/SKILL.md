---
name: liftoff
description: >
  The launch director. Runs the full pre flight readiness checklist, blocks
  the release if anything fails, then performs the release itself, small
  circle first. Use this whenever the user says "ship it", "release",
  "deploy", "submit to the store", "go live", or when the plan's current
  milestone is complete. Nothing goes in front of real users without this
  skill.
---

# /liftoff

The launch director. "It works on my machine" and "it works for thousands
of strangers" are different universes. This skill bridges them.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## When to run

- A feature or milestone is verified, tested, reviewed, and ready for users.

## When NOT to run

- Anything on the checklist below is not yet true. This skill blocks; that
  is its job, and it says so plainly instead of shipping hopeful.

## Pre-flight

1. Read AGENTS.md, docs/scope/, and the evidence under docs/evidence/ for
   everything in this release. GA tagged features must carry the human
   "approved" line in their verify report.
2. Call /warden for the security sweep if one has not run on this release.

## The readiness checklist (every line must pass)

1. The complete primary journey runs on a REAL device or normal browser,
   not just the development setup.
2. The ugly cases hold: no internet, slow internet, empty inputs, absurdly
   long inputs, denied permissions.
3. Phones: tested on both iOS and Android, and the actual production build
   tested on a real device before submission (it behaves differently than
   the development version).
4. Development leftovers removed: test buttons, debug messages, fake data.
5. Secret scan clean, including git history (from /warden).
6. The three instruments are wired and confirmed emitting:
   error tracking (tells you when the app crashes for a user, before they
   tell you), analytics (counts what users actually do, so the success line
   from the plan is measurable), logging (the app's diary, for
   investigating problems).
7. The rollback plan is written: exactly how this release gets un-shipped
   if it goes wrong. Rehearsed, not imagined.
8. Tests green, review findings at Critical and High resolved.
9. (Open decision D3, optional line): the estimated running cost of any
   feature that calls AI per use, so the bill scales knowingly.

## The release

1. Write docs/releases/NNN-readiness.md: the checklist with proof links,
   the version, the rollback plan, and the human go decision.
2. Ship to the small circle first: friends, a test group, TestFlight (iOS)
   or internal testing (Android). Real strangers find problems you cannot
   imagine. Then open the doors.
3. Immediately after: confirm error tracking is receiving events from the
   live release. A silent tracker is a failed launch step.

## Artifact ownership

MAY write: docs/releases/, release configuration.
MUST NEVER touch: app code (fixes route back through the loop), plan rows,
decision content.

## Hand-off

Report shipped version, circle size, and the watch plan. Name the next
skill: /sync now, /scope replan once real usage data exists. Suggest a
fresh session.
