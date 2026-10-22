# Plan: build factory and three risk tests

Status: approved by Fumnanya on 19 October 2026. Nothing in this plan has been started yet.

Addition approved by Fumnanya on 19 October 2026: the `/factory` command, a live dashboard, security and design reviewers, and two factory rules. All four come from the ZazenCodes video "Build Your Own AI Software Factory with Claude Code" (7 October 2026, youtube.com/watch?v=ctoaIC4LHmI).

## Summary

Before any PuhuScribe feature is built, do two things in parallel. First, run three cheap tests on the risks that could force a redesign: the microphone on an installed iPhone app, how spoken Finnish voices sound, and how well speaking feedback works on beginners. Second, set up the "build factory": the automatic checks, the separate testing agent, and the recording setup that let Claude build features while you only approve results.

Expected cash cost: about €7 for the tests, and €0 per month for the factory during the build, apart from your Claude plan. The real cost is people's time: about 2 to 2.5 hours of your native reviewer's time and about 1 hour of yours.

---

## Part 1: The three risk tests

Each test is throwaway code. It lives in a `spikes/` folder, is never reused in the real app, and is deleted once the result is written down. Each test ends with a one page result note in `docs/risk-tests/` that says what we tried, what happened, and what it decides.

### Test 1: Microphone in an installed iPhone app

**The question:** when PuhuScribe is added to an iPhone home screen and opened from there, can it record the learner's voice and play it back reliably?

**Why it matters:** the whole Say it step depends on recording. iPhone web apps have a long record of microphone bugs. If this fails, the app needs a native wrapper (the PRD already mentions this route, called Capacitor) and the stack changes.

**What gets built:** a one page recorder. It has a record button, a stop button, a play button, and a small log of what worked. It is put online at a private, unlisted web address, because microphones only work on secure (https) pages.

**What you do (about 30 minutes):** add the page to the home screen on an iPhone and on an Android phone, then follow a short checklist.

**Pass if, on both phones:**
- 10 recordings in a row work and play back clearly.
- The microphone permission is still granted after closing and reopening the app.
- Recording still works after switching to another app and back.
- Recording works with headphones plugged in or Bluetooth connected.

**What it decides:** installable web app (as planned) or a native wrapper.

**Cost:** €0. Hosting is free (Cloudflare Pages). It needs an iPhone. If you do not own one, borrowing one is enough.

### Test 2: Spoken Finnish voices (puhekieli)

**The question:** can any synthetic voice say spoken Finnish (for example "mä oon", "kiitti", "onks teil") so that a native speaker accepts it? Or do the unit dialogues need native recordings?

**Why it matters:** both registers with audio is one of the five principles. No voice provider claims to handle puhekieli, and no published test exists. Azure, the voice the PRD names, has only 3 standard Finnish voices.

**What gets built:**
1. 10 short lines from units 1 and 2 of the PRD, each in spoken and written Finnish. Your reviewer checks the wording first.
2. Each line voiced by 4 providers: ElevenLabs, Google (Chirp 3 HD voices), Azure, and OpenAI. That is 2 to 3 voices each, about 60 to 80 clips in total.
3. A private blind listening page. Clips play in random order with no provider names shown. Your reviewer rates each clip from 1 to 5 for "sounds natural" and answers yes or no to "is this how a Helsinki adult would say it".

**What your reviewer does (about 1 to 1.5 hours):** checks the 10 lines, then does the blind listening test.

**Pass if:** at least one provider averages 4 or more out of 5 on the spoken lines, and the reviewer says yes on at least 9 of the 10 lines.

**What it decides:** which voice provider to use, or native recordings for the about 40 dialogue lines in v3.0.

**Cost:**
| Item | Cost |
|---|---|
| Azure, Google, OpenAI voices (a few thousand characters) | about €0, all inside free allowances or a few cents |
| ElevenLabs Starter plan for 1 month (the free plan has no commercial licence, and clips may appear in an episode) | $6 (the first month is currently $1) |
| Quotes from 2 to 3 Finnish voice actors, requested in parallel so we have a fallback price | free to ask |
| If native recordings win later: about 40 lines | estimate €150 to €600, not verified |

### Test 3: Speaking feedback on beginners

**The question:** when a beginner reads a line aloud, does the automatic feedback agree with what your native reviewer hears? In particular, does it catch length mistakes like *tuli* (fire) said for *tuuli* (wind), which change the meaning in Finnish?

**Why it matters:** wrong feedback is worse than none. It teaches mistakes and breaks trust. The research found no independent test of any provider on Finnish learner speech, so we have to measure it ourselves.

**What gets built:**
1. A private recording page with a consent screen. Each participant reads 15 to 20 short lines from units 1 to 3, and some lines include a deliberate length mistake.
2. Recordings from you (you are the A0 target learner). You read each line twice: once as well as you can, once with a deliberate mistake on some lines. That makes about 40 clips. More beginners can be added in a later round.
3. A script that sends every clip to the candidates:
   - Azure pronunciation assessment, which scores against the known line and officially supports Finnish
   - Plain transcription from OpenAI, Soniox, and ElevenLabs Scribe, each compared to the line
4. A labelling page where your reviewer marks each clip "said correctly" or "not correct, and where".
5. A results table showing how often each candidate agrees with the reviewer, and how many length mistakes each one caught.

**What you and your reviewer do:** you record for about 20 minutes. Your reviewer labels the clips, which takes about 45 minutes.

**Pass if:** the best candidate agrees with the reviewer on at least 85 percent of clips and catches most of the deliberate length mistakes. The exact bar is yours to set.

**What it decides:** the speaking feedback provider, and whether feedback can be phrase level only (the PRD's v3.0 plan) or needs extra length checks.

**Privacy:** participants see a plain consent text: what is recorded, who hears it, and that it is deleted when the test ends. Clips stay in a private storage location in the EU and are deleted after the result note is written. Nothing goes in git.

**Cost:**
| Item | Cost |
|---|---|
| All speech services, about 10 minutes of audio each | under €1 in total, most of it inside free allowances |

### Test cost summary

| | Cash | People's time |
|---|---|---|
| Test 1: iPhone microphone | €0 | you, 30 minutes |
| Test 2: Finnish voices | about $6 | reviewer, 1 to 1.5 hours |
| Test 3: speaking feedback | about €1 | you about 20 minutes; reviewer about 45 minutes |
| **Total** | **about €7** | **reviewer about 2 to 2.5 hours** |

Your reviewer's pay for these hours is not included. That depends on what you agreed with them.

---

## Part 2: The build factory

The factory is the setup that lets Claude build each feature with little input from you, at a high bar. It is what the best teams use today (sources in the research summary given in chat on 18 October). It replaces the manual flow where you type each skill command yourself.

### How one feature moves through the factory

1. **Spec.** You start a feature with `/factory <feature>` or `/factory next` (see "The `/factory` command" below). Claude writes a short spec for the feature from the PRD and `scope.md`, with numbered "done when" statements in plain English. **You approve it.** This is your first touchpoint.
2. **Feature list.** The feature is added to `features.json` marked "failing". It only becomes "passing" when the checks below prove it.
3. **Build.** A builder session takes that one feature on its own branch. It writes tests first, then the code. It cannot finish its turn until the automatic checks pass.
4. **Automatic checks (the hard gate),** run by GitHub on every change:
   - strict type checking, lint and formatting
   - unit tests
   - browser tests (Playwright) that click through the feature like a learner
   - database security tests that try to read another learner's data and must fail
   - a secret scan and a dependency check
   - evals for anything that uses AI (content checks, feedback, tutor)
5. **Reviewers.** Once the checks pass, two reviewer agents read the change at the same time (see "The reviewers" below). If either asks for changes, the feature goes back to step 3 with their notes.
6. **Preview.** Every change gets its own private preview web address with test data.
7. **Evaluator.** A separate Claude session with fresh context and a skeptical brief tests the live preview against the numbered "done when" list. It saves screenshots and a short video as evidence. If anything fails, the feature goes back to step 3.
8. **Your approval.** You get the preview link, the evidence, the reviewers' notes, and a 5 line plain English summary. **You approve with `/factory approve <id>` or send it back with `/factory rework <id> <note>`.** This is your second touchpoint. Finnish content also needs your reviewer's approval.
9. **Learn.** Every mistake the reviewers, the evaluator or you caught becomes a short rule in `AGENTS.md`, so it does not happen again.

Nothing merges to main without your approval in step 8. Unlike the video, no agent merges on its own.

### The `/factory` command

One Claude Code skill, `/factory`, is the single way into the factory. The session that runs it becomes the manager: it runs the steps above, starts each agent, and is the only one that writes to the factory's main status file. Each agent writes only its own file. This replaces typing each skill command yourself.

| Command | What it does |
|---|---|
| `/factory <feature>` | Starts a new job from a description you type |
| `/factory next` | Starts the next feature in `scope.md` order |
| `/factory approve <id>` | Records your approval and merges the job into main |
| `/factory rework <id> <note>` | Sends the job back to the builder with your note |
| `/factory status` | Lists every job and where it is |

### The reviewers

Two reviewer agents run side by side after the automatic checks. They add judgement the checks cannot give. They do not replace the checks or the evaluator.

| Reviewer | What it looks for | Model |
|---|---|---|
| Security reviewer | Learner data exposed, keys or secrets in code, missing access rules, data leaving the EU, unsafe handling of recordings | Opus |
| Design reviewer | Screens that drift from the locked design system, broken layouts on phone sizes, unclear wording, steps a beginner could get stuck on | Sonnet |

Each reviewer writes a short pass or changes-needed note to the job's folder. The notes are part of the evidence you see in step 8.

### The live dashboard

A small local web page shows every job and the step it is on: spec, build, checks, review, evaluator, waiting for you. Clicking a job shows its spec, the reviewers' notes, the evidence and the summary. It only reads the factory's files, so it changes nothing. It runs on your computer and is never put online.

It gives you one place to see what is waiting for you. For the YouTube series, it shows the factory working: jobs moving across the steps while the agents run.

### Two factory rules

Both come from problems the video ran into.

1. **The factory's own files never block it.** `features.json`, `progress.md`, job notes and logs change all the time. The "is the working copy clean?" check before starting or merging a job ignores these files, and the manager commits them separately from feature code. In the video, unfinished changes to the backlog file stopped every automatic merge.
2. **Clear rules for what gets flagged.** Every job reaches you anyway, so these rules decide what your summary marks as "look closely" and what also goes to your Finnish reviewer:
   - anything touching learner data, recordings or consent
   - any new or changed Finnish learning content (also goes to your reviewer)
   - anything that adds a paid service or raises running costs
   - database or access-rule changes
   - anything a reviewer marked as a concern, even if it passed

   Everything else is marked "routine". In the video, the approver had no clear rules and sent almost every job for human review.

### What gets set up

| Piece | What it does | Cost |
|---|---|---|
| GitHub repository (private, created 18 October, still empty) | Code, history, and the automatic checks | €0 (GitHub Free includes 2,000 check minutes a month for private repositories) |
| Separate test and live databases (Supabase, EU region) | The agent only ever has test database access, never live | €0 during the build (2 free projects). Pro is $25 a month once real learners arrive |
| Hosting and previews (Cloudflare Pages and Workers) | The app, preview links, and the private AI and speech proxy | €0 during the build; $5 a month when traffic grows |
| Claude for the app's own AI (content drafting, tutor), via an EU region on AWS Bedrock | Keeps learner data processing in the EU for GDPR | pay per use; the six units of content are likely a few euros. Exact numbers come from the stack spec |
| `features.json`, `progress.md`, specs folder | The factory's memory between sessions | €0 |
| `/factory` skill and agent files (spec writer, builder, security reviewer, design reviewer, evaluator) | The single entry point and the agents it starts | €0 (runs on your Claude plan) |
| Live dashboard (local page) | Shows every job and its step | €0 |
| `AGENTS.md` (short) | House rules: the five principles, the not in v3.0 list, privacy rules, no placeholders, never delete tests | €0 |
| Session limits and a cost log | Each build session has a time and spend cap, and every run's cost is written down | €0 |
| Claude Code itself | Runs the builder and evaluator sessions | your Claude plan (Pro $20 a month or Max from $100 a month). A hands off build will likely need Max. Anthropic's own example of a full app build with this kind of setup cost $124 to $200 at API prices for a 4 to 6 hour run |

**Note on Vercel:** the PRD names Vercel for the frontend, but its free plan does not allow commercial use (Pro is $20 a month). Cloudflare can host the frontend too, so the factory assumes Cloudflare. The final call belongs in the stack spec.

### Recording setup (for the YouTube series)

All of this runs without you at the desk.

| Piece | What it gives you | Cost |
|---|---|---|
| Automatic progress log (a script that runs after each Claude turn) | A dated line of what was done, which becomes your voiceover script | €0 |
| Saved session logs, replayed with claude-replay or turned into pages with Simon Willison's transcripts tool | The build itself as watchable footage, plus a public transcript as proof | €0 (open source) |
| Live dashboard screen recordings | Jobs moving across the factory steps, the clearest on-screen view of the factory | €0 |
| Browser test videos at each milestone | The "it really works" clip, recorded the same way every time | €0 (Playwright) |
| Git history timelapse (Gource) | A montage of the project growing | €0 (open source) |
| OBS screen recording as a backup | Raw screen footage | €0 (open source) |

Editing tools (Descript, Opus Clip) come later and are not priced here.

### Factory smoke test (the small sample before real work)

Before any real feature, one tiny practice feature goes through the whole factory: a page that says "Hei!" and saves one visit to the test database. It is started with `/factory`. It must pass every check, get notes from both reviewers, get a preview link, be tested by the evaluator with evidence, show on the dashboard at every step, produce a progress log and a session replay, and reach you for approval. You see the result before the factory is used for anything real.

### What happens to the installed skills kit

The factory replaces the manual command flow. The proposal:
- Keep `scope.md` as the feature list source.
- Keep the kit's good ideas inside the factory: specs with numbered "done when" statements, verifying the real app, tests, and decision records.
- Move the kit to `docs/archive/skills-kit/` once the factory works, so nothing is lost.

This is your call.

---

## Order and timing

| When | What | Who |
|---|---|---|
| Day 1 | Build Test 1's recorder page and put it online. Ask 2 to 3 Finnish voice actors for quotes. Prepare Test 2 lines for the reviewer | Claude; you approve the private test page going online |
| Day 1 to 3 | You run Test 1. Reviewer checks the 10 lines. Generate the voice clips | you, reviewer, Claude |
| Day 2 to 5 | Set up the factory and run the smoke test | Claude; you approve the smoke test result |
| Day 3 to 7 | Reviewer does the blind listening test. You record for Test 3. Reviewer labels the clips | reviewer, you |
| Day 7 to 8 | Result notes for all three tests, then the stack spec uses them | Claude writes, you decide |

Most of the waiting is on people, not code. If the reviewer is busy, Tests 2 and 3 move and everything else continues.

## Decisions made (19 October 2026)

1. **Plan:** approved.
2. **iPhone for Test 1:** your own iPhone.
3. **Reviewer:** available this week. You agree their pay with them directly.
4. **Testers for Test 3:** only you for now. With one voice the result is an early read, not a final answer. A LinkedIn call for testers later in the build is your idea for building interest; it is not part of this plan.
5. **Claude plan:** Max.
6. **Accounts:** you already have Supabase, Cloudflare, Azure, OpenAI and GitHub. ElevenLabs is new. Google Cloud is unknown: open console.cloud.google.com with your Google account; if it asks you to agree to terms or set up billing, it is new too. You create any new account; I give you the steps and where to store each key.
7. **Spending:** approved. ElevenLabs Starter for one month, plus a €10 spending cap or budget alert on each speech and voice account (Azure, Google Cloud, OpenAI, ElevenLabs). You set the caps yourself.
8. **Order changed:** the factory and a usable first version (MVP) come first. All three risk tests run after the MVP, so your reviewer first sees a finished, good-looking app. The "Order and timing" table above is replaced by this order:
   1. Set up the factory and run the smoke test.
   2. Build the MVP on the PRD's provisional choices: an installable web app, Azure voices, Azure pronunciation assessment. The voice service and the feedback service each sit behind one swappable part of the code.
   3. Run the three risk tests on the MVP. If a test picks a different provider or shows the iPhone microphone fails, that part is changed then.
   Known risk, accepted: if Test 1 fails, the recording and install parts need rework after the MVP.
9. **MVP scope:** `scope.md` items 1 to 10: the foundations plus slices 1 to 5 (first session loop, daily review, speaking feedback, accounts and personal data, units 1 to 3 content). Claude drafts the Finnish content; your reviewer checks it when the MVP is ready.

## Prices and what is not verified

Prices were checked on vendors' pages on 18 October 2026. Not confirmed:
- whether Azure's free tier includes pronunciation assessment (if not, the cost is still under €1)
- ElevenLabs' free plan licence terms (which is why the plan uses the $6 Starter month)
- Google's live price pages (the figures come from Google's search snippet of them)
- whether Supabase's free plan can choose an EU region
- the exact Claude Max price above $100
- Finnish voice actor rates (estimate only, real quotes requested on day 1)
