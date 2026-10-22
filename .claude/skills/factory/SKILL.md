---
name: factory
description: The PuhuScribe build factory. One command that takes a feature from spec to merged code through the spec writer, builder, automatic checks, security and design reviewers, evaluator and the owner's two approvals. Use when the owner types /factory, /factory next, /factory approve, /factory rework, /factory status or /factory dashboard, or asks to build the next feature.
---

# /factory

The session that runs this skill becomes the **manager**. The manager runs the line, starts every agent, and is the only writer of `factory/board.json`, `factory/features.json`, `factory/progress.md` and each job's `summary.md`. Every agent writes only its own file. The plan behind this is `docs/factory-and-risk-tests-plan.md`, Part 2.

## Commands

| Command | What the manager does |
|---|---|
| `/factory <feature description>` | Opens a new job for a feature you describe, then runs the line |
| `/factory next` | Opens a job for the first feature in `factory/features.json` with status `failing` and no job, then runs the line |
| `/factory approve <job-id>` | At "Your spec OK": continues to build. At "Your approval": merges into main |
| `/factory rework <job-id> <note>` | Writes the note into `summary.md` and sends the job back to the builder |
| `/factory status` | Lists every job, its stage and what it waits on |
| `/factory dashboard` | Starts the live dashboard (preview server `factory-dashboard`, port 4321) |

Anything after the command is free text. Read the owner's intent, not exact syntax.

## Before any job starts

1. `git status --porcelain`, ignoring `factory/` and `.worktrees/`. The factory's own files never block it. If anything else is uncommitted, tell the owner what it is in one line and ask whether to commit it first.
2. Make sure `main` is up to date with `origin/main`.
3. Read `AGENTS.md`.

## The line

Job id: `<number>-<feature-id>`, numbered from the jobs already on the board (for example `1-stack`). Job folder: `factory/jobs/<job-id>/`.

On every stage change: update the job in `board.json` (stage, `updated` time, append to `history`), append one dated line to `progress.md`, record the scene (below), commit only the factory and recording files on main with `factory: <job-id> <stage>`, and push. Never stage files outside `factory/` and `recording/`.

**Recording**: every step is filmed for the owner's YouTube series. On every stage change, with the dashboard running, save a screenshot: `node recording/shot.mjs http://localhost:4321 <scene-number>-<job-id>-<stage>`. When the evaluator saves evidence, copy the best two images into `recording/screenshots/` with the scene number. Then append a scene to `recording/scenes.md` in the same format as the ones already there: what happened, why, the commit, and the screenshot names.

1. **spec**: start `factory-spec-writer` with the feature, job id and `spec.md` path. When done, read the spec yourself. Fix nothing silently: if it is weak, send it back once with your reasons.
2. **your-spec-ok**: stop and give the owner the spec: a 5 line plain English summary, the "done when" list, any owner's calls with options and a recommendation, and the file path. The owner approves with `/factory approve <job-id>` or asks for changes. Never continue without approval. Never decide an owner's call yourself (design direction, brand, pricing, spending, publishing).
3. **build**: create the worktree `git worktree add .worktrees/<job-id> -b factory/<job-id> main`, then start `factory-builder`. If its result is `blocked`, go to **blocked**.
4. **checks**: confirm the GitHub checks on branch `factory/<job-id>` passed (`gh run list --branch factory/<job-id>`). Until the checks exist, rely on the builder's local results and say so in the summary. Failures go back to step 3 with the output.
5. **review**: start `factory-security-reviewer` and `factory-design-reviewer` at the same time, in parallel. Any `changes needed` goes back to step 3 with their notes.
6. **preview**: get the preview link for the branch. Until previews exist, give the evaluator the command to run the app from the worktree, and say so in the summary.
7. **evaluate**: start `factory-evaluator` with fresh context. `fail` goes back to step 3 with its report.
8. **your-approval**: write `summary.md`: 5 plain lines on what changed for a learner, the preview link, the evidence folder, the reviewers' notes, the check results, and the flag (see below). Stop and tell the owner. They approve with `/factory approve <job-id>` or send it back with `/factory rework <job-id> <note>`. Finnish learning content also lists what the native reviewer needs to check.
9. **merged**: on approval, from the main checkout: `git merge --no-ff factory/<job-id> -m "Merge factory/<job-id>: <feature name>"`, push, remove the worktree, set the feature to `passing` in `features.json`, and tick its boxes in `docs/scope/scope.md`.
10. **learn**: for every mistake a reviewer, the evaluator or the owner caught in this job, add one short rule under "Lessons learned" in `AGENTS.md` (commit it with the merge).

**Rounds**: each return to step 3 is a round. After 3 rounds, stop the job at **blocked**.

## Faster mode (owner decision, 21 October 2026)

The default for every job from job 6 on. Steps 5 to 7 change as follows.

- **Full checks only when the job is flagged for learner data, recordings or consent, sign in, secrets, or database access rules.** Those jobs keep both reviewers and the full evaluator.
- **Every other job gets one combined review**: start only `factory-design-reviewer`, and add to its brief a short security checklist (no keys in code or logs, no learner data in the browser, no new third-party script). Start the evaluator at the same time, in parallel.
- **The evaluator tests what a learner would notice**: each "done when" statement in the running app, plus anything touching security or personal data. It skips break-testing the project's own tooling unless the job changed that tooling.
- **Only must-fix findings start a new round.** Should-fix items and notes go into `factory/todo.md` with the job id, for the owner to schedule.
- **Before asking the owner to choose anything visual, show one plain overview page** that names each picture and how the pieces fit.
- **Before researching a direction, ask the owner what they already have** (an earlier version, a design file, a brand).

## Parallel mode (owner decision, 21 October 2026)

The default from job 6 on, together with faster mode. The owner is tired of waiting and wants the remaining MVP jobs to run side by side. The run instructions for this stretch are in `factory/run-plan.md`.

- **Waves.** Jobs that do not need each other run at the same time, each in its own worktree (`.worktrees/<job-id>`, branch `factory/<job-id>`) and with its own builder. A job that needs another job's merged code waits for that merge. `factory/run-plan.md` lists the waves.
- **One approval for routine jobs.** A job not flagged `ga` and with no owner's call in its spec skips "your-spec-ok" and goes spec, build, checks, review, evaluate, then the owner's one approval. If the spec turns up an owner's call (design direction, brand, pricing, spending, publishing, a new paid service), the job stops at "your-spec-ok" for that call only.
- **GA jobs keep both approvals.** The spec approval and the final written "approved" line. The manager batches them: one message with every spec that is waiting, and later one message with every job that is waiting.
- **Only the manager writes shared files** (`board.json`, `features.json`, `progress.md`, `summary.md`, `recording/scenes.md`). Builders never touch them, so parallel jobs cannot collide.
- **Merging.** Merge one approved job at a time. After each merge: pull main into the other open worktrees (`git merge main` in the worktree), re-run their checks, and run `npm ci` in the main checkout if the commit check changed. Wait for the merge run on main to finish before the next push to main.
- **Database changes.** Each migration gets a unique timestamp. If two open jobs both add migrations, the second merged one renames or rebases its migration on top of the first before its checks run again.
- **Do not stop to report.** Keep every job moving. Report to the owner only when a job needs an approval, an owner's call, or is blocked.

**blocked**: write the reason in `summary.md`, tell the owner in plain English what is stuck and the options, and wait.

## Flags

Every job reaches the owner. The flag tells them how closely to look. Mark the job **look closely** if it touches any of these, and name which:

- learner data, recordings or consent
- new or changed Finnish learning content (also goes to the native reviewer)
- a paid service or higher running costs
- database or access rule changes
- anything a reviewer marked as a concern, even if it passed

Everything else is **routine**.

## Board format

`factory/board.json`:

```json
{
  "jobs": [
    {
      "id": "1-stack",
      "feature": "stack",
      "title": "Stack & architecture",
      "stage": "build",
      "round": 1,
      "flag": "look closely",
      "flag_reasons": ["paid service"],
      "waiting_on": "builder",
      "updated": "2026-10-20T09:14:00+03:00",
      "history": [{ "stage": "spec", "at": "2026-10-20T08:50:00+03:00" }]
    }
  ]
}
```

Stages, in order: `spec`, `your-spec-ok`, `build`, `checks`, `review`, `preview`, `evaluate`, `your-approval`, `merged`, plus `blocked`.

## Talking to the owner

The owner directs and does not read code. Short, plain English. Lead with what they need to do, if anything. Explain choices by their consequences. Never ask them about git pushes: push finished factory work to the private repo automatically.
