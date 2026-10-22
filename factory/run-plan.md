# Run plan: the rest of the MVP, in parallel

Owner decision, 21 October 2026: run the remaining MVP jobs side by side, as fast as possible, and do not stop to report. This file is the instruction for the manager session that runs it. It sits on top of `.claude/skills/factory/SKILL.md` (faster mode and parallel mode) and `AGENTS.md`.

## The goal

Scope items 5 to 10 built, checked and merged, with the app usable end to end: a guest does a first session (Hear it, Understand it), says lines back with feedback (Say it), comes back for review (Keep it), can make an account, and units 1 to 3 exist. The native reviewer approves the Finnish at the end as one batch.

## Who does what

- **Manager** (this session, Sonnet 5.5, high effort): runs the board, starts agents, merges, updates shared files, records scenes. Never writes feature code.
- **Builders**: one `factory-builder` per job, each in its own worktree, started in the background, so several run at once.
- **Reviewers and evaluator**: as in faster mode.
- **Owner**: approves, and makes the owner's calls (design direction, brand, pricing, spending, publishing, new paid services). Nothing else.

## The waves

| Wave | Job id | Feature | Flag | Needs first |
|---|---|---|---|---|
| 1 | `6-pr-local-db` | Pull-request browser tests against a throwaway local database | routine | nothing |
| 1 | `7-content-pipeline` | Content pipeline and native review (scope item 5) | ga, look closely | nothing |
| 1 | `8-first-session` | First session loop, Hear it and Understand it (scope item 6) | ga, look closely | nothing to start. It reads the data model and the design system. |
| 2 | `9-daily-review` | Daily review, Keep it (scope item 7) | routine, learner data | 8 merged |
| 2 | `10-speaking-feedback` | Speaking feedback and voice consent (scope item 8) | ga, look closely | 8 merged |
| 2 | `11-accounts` | Accounts and personal data (scope item 9) | ga, look closely | 8 merged |
| 2 | `12-units-1-3` | Units 1 to 3 content (scope item 10) | look closely, Finnish content | 7 merged |

Rules for waves:

- Wave 1 specs start now, all at once. Wave 2 specs start as soon as the spec of `8-first-session` is written, so they can refer to it. Wave 2 builds start when their "needs first" job is merged.
- `7-content-pipeline` and `8-first-session` share one contract: what a published dialogue looks like for the app. The data model (`3-data-model`) already defines it. Neither job may change it. If one needs a change, the manager stops both, settles it in one place, and restarts.
- No fake data in the app. Test fixtures are allowed in tests and in a clearly named test seed for the test database only. The learner never sees unapproved Finnish.
- `10-speaking-feedback` needs an Azure Speech resource in an EU region. Ask the owner for it at the moment the spec is written, with the one-line steps. Everything else in the job is built against the provider module with a recorded fake in tests, and nothing waits.

## Approvals

- Routine jobs: one approval at the end.
- GA jobs: spec approval, then the final written "approved" line. Batch them. One message to the owner lists every spec that waits, one question per owner's call, with a recommendation.
- Anything that spends money or adds a paid service is an owner's call, even in a routine job.

## Speed rules

- Start every independent agent in the same message, in the background.
- A builder runs the local checks itself and pushes the branch. The manager does not re-run them. It reads the GitHub results.
- Only must-fix findings start a round. Everything else goes to `factory/todo.md`.
- Do not wait on the owner for anything that is not an approval, an owner's call or a blocker. Work on the other jobs meanwhile.
- Keep the recording going: add a scene to `recording/scenes.md` (with a screenshot where one exists) at every merge, owner approval and owner setup step. Never pause or drop it without telling the owner in the same message.
- Watch the running costs (GitHub check minutes, API spend) and warn the owner with a number as soon as a limit comes in sight, before it blocks work.
- Keep updates to the owner to three short lines when something needs them: what is waiting, what you recommend, what it costs in time.

## Safety rules that stay on (no exceptions)

- Never print, search or grep `.env*`. Never put a key in chat.
- Agents use only the test database. Never skip a check (`--no-verify`, `LEFTHOOK=0`).
- Never push to a public repo. Auto-push to the private repo.
- Ask which email address to use, every time one is needed.
- Do not relay version 2 side-session news here.
- The banned list in `AGENTS.md` ("Not in v3.0") stays binding.

## Done

The MVP is done when `factory/features.json` shows `passing` for every feature through `units-1-3`, main is green, and the owner has the final list for the native reviewer. Then the three risk tests start.
