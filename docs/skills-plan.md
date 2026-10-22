# Skills Build Plan

The living plan for building our skill system. This file follows the same
plan.md format the playbook prescribes, because the skill system is itself a
project and gets treated like one.

One skill at a time. Each skill goes through its own mini build loop:
draft it from SKILL-TEMPLATE.md, test it on 2 or 3 real prompts, review the
result, refine, commit. Only proof moves a row to done.

## Ground documents (read these before building anything)

- builders-playbook-v2.html ... the operating manual: what every skill does
- merge-map.md ................ the construction spec: lineage, design decisions, why
- SKILL-TEMPLATE.md ........... the house style every skill copies

## Build rows, in dependency order

| # | Skill | Status | Weight | Done when |
|---|-------|--------|--------|-----------|
| 01 | /audit | drafted | medium | On a fresh project it interviews me and writes a complete AGENTS.md; on an existing project it documents the real conventions without overwriting human rules. |
| 02 | /scope | drafted | medium | It turns an idea into docs/plan.md with status, weight, and done when per feature, and a bare run reads the plan back with "here is where you are, here is what is next." |
| 03 | /architect | drafted | heavy | A feature conversation produces a numbered decision record with acceptance criteria, recommends with reasons, refuses to write code, and asks the three threat model questions for heavy features. |
| 04 | /develop | drafted | heavy | It builds one feature from its decision record, and when asked to build something undecided it STOPS and routes to /architect instead of inventing. The gate is the test. |
| 05 | /check (verify mode) | drafted | heavy | It runs the app against each acceptance criterion and saves labeled evidence files into docs/evidence/. |
| 06 | /test | drafted | medium | It writes tests for the latest changes, labels each with the criterion number it covers, and lists unautomatable criteria on an honest manual checklist. |
| 07 | /check (review mode) | drafted | medium | It produces a severity ranked findings file in docs/reviews/ using the universal review prompt, run on a different model than wrote the code. |
| 08 | /canvas (design mode) | drafted | medium | It runs the research, generates assets in the locked order (brand element first, then everything in its style, then empty, success, error states), and writes the design system file. |
| 09 | /sync | drafted | medium | After a feature lands it ticks verified plan boxes, advances decision statuses, adds learned rules to AGENTS.md, and reports every edit it made. |
| 10 | /document | drafted | light | It writes the plain change description from what actually changed, never from imagination. |
| 11 | /debug | drafted | medium | Its first move is the three way triage (real bug, polluted session, wrong decision), and for real bugs it reproduces before theorizing and ends with a regression test. |
| 12 | /warden (scan mode) | drafted | medium | It sweeps for leaked secrets, vulnerable dependencies, and risky paths, and reports findings by severity without editing code. |
| 13 | /liftoff | drafted | medium | It runs the full pre flight checklist, blocks on failures, and records readiness before any release. |
| 14 | /canvas (drift mode) | drafted | light | It scans recent UI changes against the locked design system and flags violations. |

## Deferred by design (do not build yet)

| Skill | Unlocks when |
|-------|--------------|
| /check (eval mode) | The first AI powered feature exists and needs a golden set. |
| /fleet | The single agent loop has been boringly reliable for weeks. |
| /nightshift | Same as /fleet, plus /check verify evidence is trusted. |

## Open decisions (decide during the build, not before)

| # | Decision | Affects | Status |
|---|----------|---------|--------|
| D1 | Stub first testing for heavy features: write failing tests before building? | /test, /develop | open |
| D2 | Build a hook layer (mechanical pre commit tripwires) now or later? | /warden, /sync | open |
| D3 | Where does cost metering live: /liftoff checklist line, /sync report line, or its own skill? | /liftoff, /sync | open |
| D4 | Trajectory evals: grade only AI feature outputs, or also the path taken? | /check | open |
| D5 | Keep drift inside /canvas, or split it into its own skill? (flagged in merge-map) | /canvas | open |
| D6 | Keep security split across three homes, or centralize into one /warden? (flagged in merge-map) | /warden, /architect | open |

## Working agreement for this build

- Build in row order. Rows 01 and 02 first, because every later skill reads their outputs.
- After each skill passes its "done when" test on real prompts, commit it before starting the next.
- Every lesson learned while building one skill gets folded back into SKILL-TEMPLATE.md so the next skill starts smarter.
