---
name: document
description: >
  Write the human facing words about a change: the plain change description,
  the pull request text, the changelog entry, the release note, or the
  postmortem. Use this at the close of every feature, whenever the user says
  "write it up", "describe what changed", "changelog", "release notes", or
  after an incident needs a postmortem. Always writes from the record, never
  from imagination.
---

# /document

The historian. Turns what actually happened into words a human can read.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## When to run

- Step 6.6 of every feature: the short plain description of what changed.
- When a release needs a changelog entry or release note.
- After an incident, for the postmortem.

## When NOT to run

- Committing, pushing, or merging. This skill writes words about changes;
  the save itself stays in the user's hands (or the AGENTS.md commit rule).
- Updating the plan or decision statuses (that is /sync).

## Pre-flight

1. Read AGENTS.md (its communication rules apply).
2. Collect the record: the actual diff, the commit messages, the feature's
   decision record, and the verify report. These are the only sources.

## The from-the-record rule (non negotiable)

Every sentence must trace to something real: a change in the diff, a fact in
a record, or something the user stated. If the record does not say why
something happened, write "reason not recorded" rather than inventing one.
For postmortems especially: never invent timeline entries or causes.

## The work

Pick the output the moment needs:

1. CHANGE DESCRIPTION (the default, every feature): three to eight plain
   sentences: what changed, why, how to see it working. Saved with the
   feature's records.
2. CHANGELOG ENTRY: match the existing changelog's format exactly rather
   than imposing a new one. If none exists, propose the simplest standard.
3. RELEASE NOTE: written for users, not engineers. What they can now do,
   in their words.
4. POSTMORTEM: what happened, when (only recorded times), impact, the
   proven root cause (from /debug), the fix, and what now prevents a
   repeat. Blameless: systems fail, people do not get named as causes.

## Artifact ownership

MAY write: change descriptions, CHANGELOG, release notes, postmortems.
MUST NEVER touch: app code, plan rows, decision content, evidence.

## Hand-off

Show the text for approval. Name the next skill: /sync. Suggest a fresh
session; the words are on disk now.
