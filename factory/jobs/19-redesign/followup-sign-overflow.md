# Follow up: road signs past the screen edge at 320 px (19-sign-overflow)

Quick lane follow up to job 19-redesign, merged at 2ad3d9f. Branch `factory/19-sign-overflow`, rebased onto origin/main 7bd4e8c (part 1 of the road published, Keep it fix 2d568c8), pull request [#14](https://github.com/fumnanyanketa/puhuscribe-v3/pull/14), not merged.

## Round 2: number pins (the owner's choice, 2 November)

The owner saw round 1's picture at 200 percent and said it "doesn't look good at all": the signs covered the sun and the fells. The owner chose "Number pins only".

### What changed

When the text is too large for the drawn signs, every sign becomes a small round pin on its pole. A pin shows the stop number, or a tick when the stop is done, and no visible name. The colours are the drawn signs' own: done is mint with a white tick, current a mint ring with the number in deep mint, next a peach ring, later milky. Code: `src/road/sign-pins.ts` (new), `src/road/RoadPicture.tsx`, `src/road/RoadPicture.module.css`, `src/screens/RoadScreen.tsx`.

- The road switches to pins when the text is at 200 percent or more, when any name would wrap onto a second line, or when the signs still cover the sun or a fell label after the road has dropped to two signs. When the text size or the screen changes, the road tries the drawn signs again and decides once more.
- Each pin keeps its full stop name for screen readers. The list reads, for example, "Stop 6, Small talk: weather and the weekend, current", as before. The card below keeps the current stop's full name.
- Pins stay inside the picture in every frame, through the same clamp as round 1.
- At normal text size nothing changes from round 6. I recorded every board's place in 15 road states (5 progress states at 320 x 640, 375 x 812 and 390 x 844) in both browsers, before and after pins: all 15 are identical in both.
- One case to know about: on a 320 x 568 phone (the first iPhone SE size) at normal text, with stop 5 or 6 current, the road now shows pins. There, even two drawn signs still covered the sun or a fell label, which is the owner's rule for pins (`sign-overflow-320x568-100-pins.png`). No other state I measured shows pins at normal text.
- The reference page decides by itself with the same rules (200 percent, or a name that wraps), so its road pictures are pins at 200 percent too.

### Tests (written first, red before pins)

Added to `e2e/road-sign-overflow.spec.ts`, each in Chromium and WebKit:

| Test | Statement | Before pins | With pins |
|---|---|---|---|
| 320 and 375 px, text at 200 percent, four road states (longest name current, longest name upcoming, stop 3 current, first stop): every sign is a round pin under a quarter of the screen wide, shows only its number or tick, no name; none overlaps the sun with its A1 or the B1, B2 and A2 labels; none passes the edge; the list's accessibility tree has each stop's full name; the card's heading is the current stop's full name | redesign 13, 46 | red (8 per browser) | pass |
| 320 and 375 px: when the text grows to 200 percent the signs become pins, and no pin passes the edge in any frame | redesign 13, 46 | red | pass |
| 320 and 375 px, normal text: no pins, done signs show a tick and the name, the current sign its number and the name, upcoming signs the name only, each a wide one line pill | redesign 13 | pass | pass |
| The reference page shows pins at 320 px with text at 200 percent | design 7, redesign 46 | red | pass |

Two earlier tests changed, with the reason:

- My round 1 test "text at 200 percent from the start" looked for the long name in the sign's text. With pins it checks that the current sign and the one after it show, and the name is checked by the new accessibility tree test instead. My round 1 normal text test counted the board's parts to find a number; the board now always holds the pin number (hidden as a drawn sign), so it counts only the parts shown.
- `e2e/redesign-road.spec.ts`, "[redesign 13] a stop name is rendered as text, never as markup". Its 40 letter made up name wraps on a drawn sign, so by the owner's rule the sign is a pin and the name is not shown on it. The test now finds the name as plain text in the card's heading and in the sign's list item. It still checks that no image was made and no script ran.

### Checks

- `npm run check:code`: pass. Unit tests: 1186 passed, 2 skipped, with 2 timeouts under load in `scripts/hooks/commit-tool.test.ts` (as in round 1); that file passed alone (13 of 13). This change does not touch it.
- Local browser tests against this branch's build: `e2e/road-sign-overflow.spec.ts`, `e2e/redesign-road.spec.ts` and `e2e/design-reference.spec.ts`: all pass except the WebKit "[design 9] Tab reaches every control" test, which fails the same way on main on this computer (see round 1).
- Pull request checks on 4d65fda, run [41595674122](https://github.com/fumnanyanketa/puhuscribe-v3/actions/runs/41595674122): every job that tests the code passed, including "Browser tests (Playwright, local Supabase)" with all the new pin tests in both browsers. The "Preview link" job did not pass: every test it ran against the deployed preview failed after about 5 seconds waiting for the page (pages this change does not touch too, such as the privacy notice and the Hear it sample), and GitHub cancelled the job at its time limit. The same job was cancelled the same way on this pull request's round 1 head (0760b9b, run 41591514346) and failed on the other recent pull requests, so it is a problem with the preview, separate from this change. Someone with access should look at the preview link and its Access token.

### Evidence

In `factory/jobs/19-redesign/evidence/`, Chromium, stop 5 current:

- `sign-overflow-320-200-pins.png`: 320 x 640 at 200 percent. Left, round 1 (signs over the sun and the fell labels). Right, number pins.
- `sign-overflow-375-200-pins.png`: 375 x 812 at 200 percent, number pins.
- `sign-overflow-320x568-100-pins.png`: 320 x 568 at normal text, the one small phone case that now shows pins.

Round 1 follows, kept for the record. Its two "worth a look" items are settled by the pins: at 200 percent no sign covers the A2 label any more. The road still shows drawn signs for a frame or two after the text grows, until it switches to pins; they stay inside the screen in those frames.

# Round 1: signs kept inside the screen

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
