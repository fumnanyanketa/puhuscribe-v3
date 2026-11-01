# Proof by breaking the new protections of round 2

Each protection of job 19-redesign was broken on purpose in the working copy, its test was run and had to go red, and the break was undone. Unit and repository tests run with vitest; browser tests run with Playwright (Chromium) against the running app with the test mocks. Nothing here was committed.

## 1. Page content starts on the hills again (the header loses its minimum height) (statement R1)

- Break: in `src/components/PageFrame.module.css`, `min-height: calc(var(--page-content-top) + env(safe-area-inset-top, 0p` became `min-height: 0;`
- Command: `npx playwright test e2e/redesign-pages.spec.ts --project=chromium --reporter=line -g "privacy notice: the first text of the content starts below the landscape at 375 x 812"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBeGreaterThanOrEqual(expected)
Expected: >= 160
Received:    76
test-results\redesign-pages-every-page--56522-cape-at-375-x-812-text-100--chromium\test-failed-1.png
1 failed
```

## 2. The Delete my account link goes back to the colour that fails on the wash (statement R2)

- Break: in `src/screens/Account.module.css`, `color: var(--color-danger-ink);` became `color: var(--color-peach-deep);`
- Command: `npx vitest run tests/redesign-rules.test.ts -t "Delete my account"`
- Result: RED, the test failed as it should

```
❯ tests/redesign-rules.test.ts (9 tests | 1 failed | 8 skipped) 18ms
× [redesign 6] the "Delete my account" link uses a colour whose pair on the peach end of the wash is in the contrast list at 4.5 to 1 14ms
Test Files  1 failed (1)
Tests  1 failed | 8 skipped (9)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 1 ⎯⎯⎯⎯⎯⎯⎯
FAIL  tests/redesign-rules.test.ts > small text placed straight on the wash > [redesign 6] the "Delete my account" link uses a colour whose pair on the peach end of the wash is in the contrast list at
TypeError: actual value must be number or bigint, received "undefined"
```

## 3. The mint road is drawn as a share of 36 stops again (statement R3)

- Break: in `src/road/RoadPicture.tsx`, `travelledTo={travelledTo > 0 ? (marker?.t ?? travelledTo) : 0}` became `travelledTo={travelledTo}`
- Command: `npx playwright test e2e/redesign-road.spec.ts --project=chromium --reporter=line -g "mint travelled road"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBeLessThan(expected)
Expected: < 12
Received:   384.715576171875
test-results\redesign-road-the-home-scr-93314-and-is-not-drawn-on-day-one-chromium\test-failed-1.png
1 failed
```

## 4. The words of a line get their 44 px height back as spacing (statement R4)

- Break: in `src/components/FinnishLine.module.css`, `margin: calc((var(--leading-line) * 1em - var(--tap-min)) / 2) -0.08em` became `margin: 0 -0.08em;`
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "1.4 apart"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBeLessThan(expected)
Expected: < 1.6
Received:   1.894736842105263
test-results\redesign-lesson-Hear-it-an-18101-ord-is-still-a-44-px-target-chromium\test-failed-1.png
1 failed
```

## 5. The changed word loses its peach ring (statement R5)

- Break: in `src/components/FinnishLine.module.css`, `box-shadow: inset 0 0 0 1px var(--color-peach);` became `box-shadow: none;`
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "spoken dot is mint"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBe(expected) // Object.is equality
Expected: "rgb(219, 114, 73) 0px 0px 0px 1px inset"
Received: "none"
test-results\redesign-lesson-Hear-it-an-70aa2-h-on-its-wash-in-both-lines-chromium\test-failed-1.png
1 failed
```

## 6. Understand it puts its line box inside a second card again (statement R6)

- Break: in `src/screens/LineCard.tsx`, `styles.cardBare} ${styles.cardNow}` : styles.cardBare}` became `styles.card} ${styles.cardNow}` : styles.card}`
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "one milky card"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBe(expected) // Object.is equality
Expected: "rgba(0, 0, 0, 0)"
Received: "rgb(251, 253, 252)"
test-results\redesign-lesson-Understand-20bfa-rd-not-a-card-inside-a-card-chromium\test-failed-1.png
1 failed
```

## 7. A "Back to your account" button comes back on the ready screen (statement R7)

- Break: in `src/screens/AccountPage.tsx`, `<h1 className={styles.readyTitle}>{READY}</h1>` became `<h1 className={styles.readyTitle}>{READY}</h1><Button variant="quiet">Back to your account`
- Command: `npx playwright test e2e/redesign-pages.spec.ts --project=chromium --reporter=line -g "redesign 37"`
- Result: RED, the test failed as it should

```
Error: expect(locator).toHaveCount(expected) failed
Expected: 0
Received: 1
14 × locator resolved to 1 element
- unexpected value "1"
test-results\redesign-pages-the-account-b6e15-lace-with-a-Download-button-chromium\test-failed-1.png
1 failed
```

## 8. Privacy section headings go back to mint (statement R8)

- Break: in `src/screens/Account.module.css`, `letter-spacing: normal;   color: var(--color-text); }  .shortText` became `letter-spacing: normal;   color: var(--color-mint-deep); }  .shortText`
- Command: `npx playwright test e2e/redesign-pages.spec.ts --project=chromium --reporter=line -g "section headings are ink"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBe(expected) // Object.is equality
Expected: "rgb(27, 42, 38)"
Received: "rgb(26, 111, 93)"
test-results\redesign-pages-delete-feed-1bab3-ans-a-control-you-can-press-chromium\test-failed-1.png
1 failed
```

## 9. The Keep switch goes back to its short hint, without the consent sentence (statement R9)

- Break: in `src/screens/VoiceSettings.tsx`, `hint={`${state.retention ? 'On.' : 'Off.'} ${voiceNotice(state.region)` became `hint={state.retention ? 'On.' : 'Off.'}`
- Command: `npx playwright test e2e/redesign-pages.spec.ts --project=chromium --reporter=line -g "Keep switch says what keeping means"`
- Result: RED, the test failed as it should

```
Error: expect(locator).toHaveAccessibleDescription(expected) failed
Expected pattern: /Off\. Keep my recordings so I can hear my progress\. We keep your first and latest try of each line for 90 days\. You can delete them at any time\./
Received string:  "Off."
14 × locator resolved to <button type="button" role="switch" aria-checked="false" aria-labelledby="_r_4_" class="_switch_18ss0_29" aria-describedby="_r_5_">…</button>
- unexpected value "Off."
test-results\redesign-pages-Voice-setti-f0a68--the-consent-version-covers-chromium\test-failed-1.png
1 failed
```

## 10. The privacy page voice section goes back to naming no country (statement R10)

- Break: in `src/screens/PrivacyPage.tsx`, `const notice = voiceNotice(region)` became `const notice = voiceNotice(null)`
- Command: `npx playwright test e2e/redesign-pages.spec.ts --project=chromium --reporter=line -g "with the Keep sentence and the country"`
- Result: RED, the test failed as it should

```
Error: expect(locator).toBeVisible() failed
Expected: visible
Error: element(s) not found
test-results\redesign-pages-delete-feed-c909d-ep-sentence-and-the-country-chromium\test-failed-1.png
1 failed
```

## 11. The privacy page leaves out the Keep sentence (statement R11)

- Break: in `src/screens/PrivacyPage.tsx`, `<p className={styles.shortText}>{notice.keepBox}</p>` became ``
- Command: `npx playwright test e2e/redesign-pages.spec.ts --project=chromium --reporter=line -g "with the Keep sentence and the country"`
- Result: RED, the test failed as it should

```
Error: expect(locator).toBeVisible() failed
Expected: visible
Error: element(s) not found
test-results\redesign-pages-delete-feed-c909d-ep-sentence-and-the-country-chromium\test-failed-1.png
1 failed
```

## 12. A progress piece not reached loses its edge (statement R12)

- Break: in `src/road/RoadTop.module.css`, `box-shadow: inset 0 0 0 1px var(--color-control-edge);` became `box-shadow: none;`
- Command: `npx playwright test e2e/redesign-road.spec.ts --project=chromium --reporter=line -g "hollow"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBe(expected) // Object.is equality
Expected: "rgb(30, 133, 111) 0px 0px 0px 1px inset"
Received: "none"
test-results\redesign-road-the-home-scr-3925d-a-reached-one-is-solid-mint-chromium\test-failed-1.png
1 failed
```

## 13. The finish dock goes back to no fill and no edge (statement R13)

- Break: in `src/components/SessionFrame.tsx`, `finished ? `${styles.actions} ${styles.actionsSoft}` : styles.actions` became `styles.actions`
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "milky bar"`
- Result: RED, the test failed as it should

```
Error: expect(received).not.toBe(expected) // Object.is equality
Expected: not "rgba(0, 0, 0, 0)"
test-results\redesign-lesson-the-finish-5abe5-he-new-words-not-a-hard-cut-chromium\test-failed-1.png
1 failed
```

## 14. The crash screen words start on the hills again (statement R14)

- Break: in `src/components/CrashBoundary.module.css`, `padding: var(--page-content-top) var(--space-5) var(--space-7);` became `padding: var(--space-7) var(--space-5);`
- Command: `npx vitest run tests/redesign-rules.test.ts -t "crash screen"`
- Result: RED, the test failed as it should

```
❯ tests/redesign-rules.test.ts (9 tests | 1 failed | 8 skipped) 11ms
× [redesign 4] [redesign 41] the crash screen starts its words below the landscape, like every page 10ms
Test Files  1 failed (1)
Tests  1 failed | 8 skipped (9)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 1 ⎯⎯⎯⎯⎯⎯⎯
FAIL  tests/redesign-rules.test.ts > small text placed straight on the wash > [redesign 4] [redesign 41] the crash screen starts its words below the landscape, like every page
AssertionError: expected '.page {\n  position: relative;\n  dis…' to match /padding:\s*var\(--page-content-top\)/
- Expected:
+ Received:
```
