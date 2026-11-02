# Proof by breaking the new protections of round 5

Each protection of job 19-redesign was broken on purpose in the working copy, its test was run and had to go red, and the break was undone. Unit and repository tests run with vitest; browser tests run with Playwright (Chromium) against the running app with the test mocks. Nothing here was committed.

## 1. A tall word button pulls its first row up over the row above again (the old margin and no padding) (statement R1)

- Break: in `src/components/FinnishLine.module.css`, `margin: calc(-1 * var(--pad)) -0.08em;   padding: var(--pad) 0;` became `margin: calc((var(--leading-line) * 1em - var(--tap-min)) / 2) -0.08em;   padding: 0;`
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "21 letter tappable"`
- Result: RED, the test failed as it should

```
Error: the word overlaps the text row above
expect(received).toBeLessThanOrEqual(expected)
Expected: <= 1
Received:    9.09375
test-results\redesign-lesson-phone-size-5d59d-tart-at-the-left-in-Hear-it-chromium\test-failed-1.png
Error: the word overlaps the text row above
expect(received).toBeLessThanOrEqual(expected)
Expected: <= 1
Received:    9.09375
test-results\redesign-lesson-phone-size-ba72e-start-at-the-left-in-Say-it-chromium\test-failed-1.png
```

## 2. The pieces of a wrapped tappable word are centred again (statement R2)

- Break: in `src/components/FinnishLine.module.css`, `text-align: start;` became ``
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "21 letter tappable"`
- Result: RED, the test failed as it should

```
Error: the pieces of the word are not left aligned
expect(received).toBeLessThan(expected)
Expected: < 1
Received:   85.203125
test-results\redesign-lesson-phone-size-5d59d-tart-at-the-left-in-Hear-it-chromium\test-failed-1.png
Error: the pieces of the word are not left aligned
expect(received).toBeLessThan(expected)
Expected: < 1
Received:   52.765625
test-results\redesign-lesson-phone-size-ba72e-start-at-the-left-in-Say-it-chromium\test-failed-1.png
```

## 3. The Speaking feedback switch is not given back focus by the consent sheet (statement R3)

- Break: in `src/screens/VoiceSettings.tsx`, `returnFocus={speakingSwitch}` became ``
- Command: `npx playwright test e2e/redesign-pages.spec.ts --project=chromium --reporter=line -g "Speaking feedback switch opens the consent sheet"`
- Result: RED, the test failed as it should

```
Error: after Not now
expect(locator).toBeFocused() failed
Expected: focused
Received: inactive
14 × locator resolved to <button type="button" role="switch" aria-checked="false" aria-labelledby="_r_2_" class="_switch_18ss0_29" aria-describedby="_r_3_">…</button>
- unexpected value "inactive"
test-results\redesign-pages-Voice-setti-0acdb-ve-focus-back-to-the-switch-chromium\test-failed-1.png
1 failed
```

## 4. Say it does not give focus back to its quiet Turn on button (statement R4)

- Break: in `src/screens/SayIt.tsx`, `reopen.current?.focus()` became ``
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "quiet .Turn on speaking feedback. in Say it"`
- Result: RED, the test failed as it should

```
Error: after Not now
expect(locator).toBeFocused() failed
Expected: focused
Received: inactive
14 × locator resolved to <button type="button" class="_button_1l9wa_3 _quiet_1l9wa_83">…</button>
- unexpected value "inactive"
test-results\redesign-lesson-the-lesson-20314-ocus-back-to-it-after-a-tap-chromium\test-failed-1.png
1 failed
```

## 5. The word does not get focus back after its card closes (statement R5)

- Break: in `src/components/FinnishLine.tsx`, `back.focus()` became ``
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "tap on a word opens its card"`
- Result: RED, the test failed as it should

```
Error: after Close
expect(locator).toBeFocused() failed
Expected: focused
Received: inactive
14 × locator resolved to <button type="button" aria-haspopup="dialog" class="_word_sjrja_111">…</button>
- unexpected value "inactive"
test-results\redesign-lesson-the-lesson-9a99f-r-a-tap-that-does-not-focus-chromium\test-failed-1.png
1 failed
```
