# PuhuScribe plan

The living plan. What we build, in what order, and how we will know each part
works. This file is the map. It never picks the technology. Those choices are
decision records, made by /architect.

## What PuhuScribe is

An AI Finnish speaking coach for adults who have moved to Finland and freeze
when they try to talk. It takes them from studying Finnish to actually speaking
it in daily life.

## North star

I will know it worked when 50 learners finish onboarding and complete their
first AI FLOW conversation in Finnish without asking for help, and at least 40
percent of them come back within two weeks for another session on a different
day.

Every row below serves this.

## How to read this

- Status: planned, in progress, or done. Only proof moves a row to done. Proof
  means passing tests and recorded evidence from /check verify.
- Weight: how much care a feature gets.
  - light: small and low risk. Minimal checking.
  - medium: the standard process.
  - heavy: money, logins, or personal data. Every check plus your own written
    sign off.
- Done when: one line that says how we will know this feature works.
- Needs decision: yes means the row hides a technical choice that /architect
  must settle before it is built. The plan does not make that choice.

## The plan, in build order (heart first)

| # | Feature | Status | Weight | Done when | Needs decision |
|---|---------|--------|--------|-----------|----------------|
| 1 | App shell and navigation | planned | light | a user can move between the main screens | no |
| 2 | Onboarding and placement | planned | medium | a new user does a short intake, gets an estimated starting level, and reaches home | yes: how we estimate level, what we store |
| 3 | AI conversation (FLOW) | planned | heavy | a user holds a short Finnish exchange with the tutor at their level and gets warm correction | yes: which AI model, how we hold the level, voice or text first |
| 4 | Accounts and sign in | planned | heavy | a user signs up, signs out, signs back in, and their progress is still there | yes: which managed sign in service |
| 5 | Lesson player (WORDS and RULES) | planned | medium | a user finishes one chunk lesson and one grammar lesson taught as Origin, Logic, Rule, Exceptions, Examples | yes: where lesson content comes from |
| 6 | Practice and drills (REPS) | planned | medium | a user completes a drill set and their errors are saved | yes: how drills are made and checked |
| 7 | Review and memory (SRS) | planned | medium | due words and past mistakes return on a schedule the next day | yes: which spaced repetition method |
| 8 | Analytics and success metrics | planned | heavy | onboarding completion, first FLOW completion, and return visits are all counted | yes: which analytics tool |
| 9 | Home and daily dashboard | planned | light | a user sees their progress and today's suggested session | no |
| 10 | Profile and settings | planned | light | a user can view and edit their level, goals, and account | no |

SRS means spaced repetition. It shows an item again just before you would
forget it. It is the main reason a learner comes back, so it feeds the 40
percent return goal.

## Backlog, kept visible

Real, but not in the v1 build order yet. It competes for priority here instead
of hiding in memory.

| # | Item | Status | Weight | Done when | Needs decision |
|---|------|--------|--------|-----------|----------------|
| B1 | Language islands (personal prepared monologue blocks) | planned | medium | a learner can build, rehearse, and reuse a short personal monologue in a conversation | yes: exact scope, and how it differs from WORDS chunks |

## Notes that shape the build

- The two rails are rules, not rows. Comprehensible input (replies pitched just
  above the learner's current level, called i plus 1) and low affective filter
  (warm correction, speak before you are ready, no shame) apply inside FLOW,
  lessons, drills, and review. They become acceptance criteria in each decision
  record, not separate features.
- Grammar serves conversation. RULES is never a gate a learner must pass before
  they are allowed to speak.
- Storage and accounts are linked. Rows 2, 4, 7, and 8 all need saved data. The
  storage choice is one of the first decisions for /architect.

## Recommended next step

Run /architect for the stack (decision record 0001). It settles the load
bearing choices, including storage, the AI model for FLOW, the sign in service,
and the analytics tool. After the stack is set, the top build row is number 1,
App shell and navigation, which has no open decision.

Plan status: drafted in Phase 2. It stays alive. After each feature ships,
/sync and /scope update it against what really shipped.
