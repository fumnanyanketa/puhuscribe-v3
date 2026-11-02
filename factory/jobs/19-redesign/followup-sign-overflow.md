# Follow up: road signs past the screen edge at 320 px (19-sign-overflow)

Quick lane follow up to job 19-redesign, merged at 2ad3d9f. Branch `factory/19-sign-overflow`, rebased onto origin/main 7bd4e8c (part 1 of the road published, Keep it fix 2d568c8), pushed, not merged.

## What failed

The run after the merge, [41464799578](https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41464799578), failed one test in Chromium in the job "Browser tests against the test project (after merge)": `e2e/design-reference.spec.ts:142`, "[design 7] nothing on the reference page scrolls sideways at 320 px, also with text at 200 percent". It listed 41 parts of 8 road signs past the right edge. After part 1 of the road was published, run [41470749765](https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41470749765) failed the same test at 375 px as well as at 320 px, with the same kind of list.

## Triage

A real bug. The signs could stand past the edge of the screen for a frame or two whenever the text size changed. The test caught one of those frames.

## The cause, from evidence

The suggested cause (job 20's longer real stop names) is not it.

- The reference page never reads the road from the database. Its road pictures use the fixture in `src/road/road-fixture.ts`, and the fixture already holds the real names, the longest included ("Small talk: weather and the weekend", 35 letters).
- The app code at the branch run (3725570) and at the merge (2ad3d9f) is the same: the only changes between them are factory notes, evidence pictures and AGENTS.md.
- The branch run 41459033855 did not run this job at all. "Browser tests against the test project (after merge)" runs only on pushes to main, so it was skipped there. The test passed in a different job ("Browser tests, local Supabase") on a different machine.

The real cause is timing. A sign's board was centred on its pole by the stylesheet, and a script measured it and moved it back inside the screen if it ran past an edge. That script runs after the browser has laid the page out with the new text size, so for a moment the boards stand where the stylesheet put them. Measured on this computer with the merged code:

- Reference page, 320 px: right after the text grows to 200 percent, 8 signs stand past the edge (the same 8 signs the failed run listed). One frame later they are still out; two frames later all are inside.
- Road screen, 320 x 640, with the real names: after the text grows to 200 percent, two painted frames show boards past both edges, for example stop 5 from -11 px to 293 px and stop 7 out to 327 px. Chromium's screen recording shows one of those frames in `sign-overflow-320-200-before.png`.

Whether the test saw that moment depended on how quickly the next frame came, which is why it passed in one job and failed in the other, and why it later failed at 375 px too. The same thing happens at 375 px: the new road tests at 375 x 812 are red on main's code in both browsers.

## The fix

The stylesheet now keeps every sign inside the picture itself, so no frame ever shows a sign past the edge (`src/road/RoadPicture.module.css`, `src/road/RoadPicture.tsx`).

- The list of signs is a size container. Each sign knows where its pole stands, and its sideways move is clamped so the board stays 8 px inside the picture. A board is centred on its pole as drawn, and moves only as far as the edge needs.
- A board is never wider than the picture less 16 px, so it always fits. A long name wraps to two lines only when it would not fit on one (at 200 percent text on a 320 px phone, "Small talk: weather and the weekend" and "Getting around by bus and tram" take two lines). At 200 percent the road also shows fewer signs when they would not fit, as it already did; the current sign and the one after it always show.
- At normal text size nothing changes. I recorded every board's place in 15 road states (5 progress states at 375, 320 and 390 px) in both browsers, before and after. Where the old code had settled, the places match. A few boards near an edge sit up to 5 px closer to the 8 px line than before, because the old script sometimes stopped a few pixels short.
- Phones whose browser has no container units (before 2022: Safari 15, Chrome 104 and older) keep the old script, which still moves the boards inside after the first frame.

## Tests (written first, red on the merged code)

All in `e2e/road-sign-overflow.spec.ts`. Labels are statements of `factory/jobs/19-redesign/spec.md`.

Each road test runs at 320 x 640 and at 375 x 812, in Chromium and WebKit.

| Test | Statement | On main's code | On the fix |
|---|---|---|---|
| The published stop names are read from the migration that loads `public.road_stops`, all 36, and match `content/road/road-report.md` | redesign 13 | pass | pass |
| Text grown to 200 percent, every frame for 1.5 s, longest published name as the current sign | redesign 20, 46 | red at both widths, both browsers | pass |
| Same, longest published name as the upcoming sign (no number) | redesign 20, 46 | red at both widths, both browsers | pass |
| Same, longest published name as a done sign | redesign 20, 46 | red at both widths, both browsers | pass |
| Text at 200 percent from the start, every frame from the first sign, three places; no name cut | redesign 20, 46 | pass | pass |
| 375 px, normal text: every sign one line, pole under the board, number only on done and current signs | redesign 13 | pass | pass |
| Reference page at 320 and 375 px: the moment text grows to 200 percent, every sign is already inside | design 7, redesign 46 | red at both widths, both browsers | pass |

On main's code (7bd4e8c with the two sign files put back) 16 of the 32 tests were red, every "text grown" test and the reference test, at both widths in both browsers. On the fix all 32 pass.

The names are the ones the database serves: the test reads them from `supabase/migrations/20261101120100_load_road_stops.sql`, which writes `name_en` for all 36 stops (part 1 is stops 1 to 6), and checks they equal the content report. The longest is stop 6, "Small talk: weather and the weekend", which is in part 1. The road tests serve the fixture stops with those names, so a longer name is tested as soon as it lands. If a later migration renames a stop, this test reads only the first file and would need to read that one too. The original failing test passed 40 times out of 40 on the fix (`--repeat-each=10`, both browsers, both widths).

## Checks I ran

- `npm run check:code` (type check, lint, format): pass.
- `npm test` (unit tests): 1187 passed, 2 skipped. A first full run had 3 timeouts in `scripts/hooks/commit-tool.test.ts` under load; that file passed alone and the second full run passed. This change does not touch it.
- After the rebase: `VITE_DESIGN_REFERENCE=1 npm run build`, then `npx playwright test e2e/road-sign-overflow.spec.ts e2e/redesign-road.spec.ts e2e/design-reference.spec.ts` against a local preview of this branch: 181 passed, 1 failed. The failure is "[design 9] Tab reaches every control in reading order" in WebKit, and it fails the same way on the merged code on this computer (it passed on GitHub), so it is not from this change.
- Lefthook on both commits: format, gitleaks, ESLint and tsc pass.
- Full checks on GitHub, on the rebased head c5e00ec: [41474916863](https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41474916863) passed. Every job that runs on a branch passed, including "Browser tests (Playwright, local Supabase)", where all 32 new tests and the original test passed in both browsers (an earlier run on the head before the rebase, 41472740700, was cancelled).

The job that failed ("after merge", against the test project) runs only on pushes to main, so it cannot run on this branch. My new tests and the original test run in the branch run's "Browser tests (Playwright, local Supabase)" job. The after merge job will run them again when this is merged.

## Evidence

In `factory/jobs/19-redesign/evidence/`, all Chromium at 320 x 640, stop 5 current, the frame painted right after the text grows to 200 percent, taken from Chromium's screen recording:

- `sign-overflow-320-200-before.png`: the merged code. Boards are cut at both edges.
- `sign-overflow-320-200-after.png`: the fix, the same frame. Every board is inside the screen.
- `sign-overflow-320-200-after-settled.png`: the fix, one frame later, once the road shows fewer signs.

## Not changed, worth a look

- In the first frame after the text grows, the boards are inside the screen but still overlap each other for that one frame, until the script drops a sign (see `sign-overflow-320-200-after.png`). This is how the merged code behaves too. Making the sign count right in the first frame would mean deciding the count in the stylesheet, which is a bigger change than this follow up.
- At 200 percent on a 320 px phone with stop 5 current, the "Small talk: weather and the weekend" board covers part of the A2 fell label. The merged code does the same. The road already shows the fewest signs it allows (two) there.

## How to run it locally

```
VITE_DESIGN_REFERENCE=1 npm run build
npx playwright test e2e/road-sign-overflow.spec.ts
```

Result: checks pass
