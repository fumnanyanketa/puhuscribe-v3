---
name: skill-name-here
description: >
  [WHAT it does in one sentence.] [WHEN to use it, written pushy: "Use this
  whenever the user mentions X, asks about Y, or is doing Z, even if they do
  not say the word X explicitly."] Descriptions are the triggering mechanism,
  so list the real phrases and situations that should wake this skill up.
---

# /skill-name-here

One sentence: the single job this skill does and the artifact it produces.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## When to run

- [The moments this skill is the right tool.]
- [Entry conditions: what must already exist, for example "a plan row exists" or "a decision record exists".]

## When NOT to run

- [The neighboring jobs that belong to other skills, named. Example: "If the task needs a decision the engineer has not made, stop and route to /architect."]

## Pre-flight (read before doing anything)

1. Read AGENTS.md in full. It is the project rulebook and it wins over habit.
2. Read the relevant plan row in docs/plan.md and the linked decision record in docs/decisions/, if they exist.
3. If this skill has modes, read EXACTLY ONE mode file from modes/ that matches the request. Do not read the others. This keeps the context small and cheap.

## Asks vs acts

Three verbs, applied in this order:

- **INFER** everything the code, the files, and the conversation already reveal. Never ask the user something the project can answer.
- **ASK** only what the user alone knows: intent, business rules, taste, risk appetite. One question at a time.
- **RECOMMEND** on everything expertise settles: always present one option marked "recommended" with a one line reason, never a neutral menu.

## The work

[The numbered procedure. Keep this SKILL.md under 500 lines total. When a step
needs long instructions, a big checklist, or a full prompt, move that content
into references/ or modes/ and point to it here with a clear "read X when Y"
line. Detail files are read at the moment they are needed, never during
pre-flight. That is progressive disclosure and it is the whole trick.]

1. [Step.]
2. [Step.]
3. [Step.]

## Artifact ownership

This skill MAY write:
- [exact files or folders, for example docs/plan.md]

This skill MUST NEVER touch:
- [everything else that matters, named. Example: "decision record content (only /architect writes those)", "app code (only /develop writes that)"]

When this skill finds something wrong outside its ownership, it FLAGS it in
its report and names the skill that should fix it. It never fixes it itself.

## Team safety

- Before writing any shared file, re-read it. It may have changed.
- Make the smallest surgical edit that does the job. Never rewrite a file to change one line.
- When unsure whether an edit is safe, flag instead of writing.

## Hand-off

End every run with three things:
1. A short plain report: what was done, what was written, what was flagged.
2. The next skill in the pipeline, named.
3. The suggestion to start a fresh session if this one has grown long. All state is in files, so nothing is lost.

## Bundled resources

- modes/ holds one file per mode. Read exactly one, at run time.
- references/ holds long instructions, checklists, and full prompts. Read a file only when a step points to it.
- templates/ holds file skeletons this skill copies when creating its artifacts.

## Portability note

Shell commands in this skill are POSIX reference, not literal scripts: they
describe WHAT to do, and the agent should achieve the same result with its
own built in tools so the skill works on any operating system. Git commands
are the exception and may be run exactly as written.
