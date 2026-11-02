# Proof by breaking the new protections of round 4

Each protection of job 19-redesign was broken on purpose in the working copy, its test was run and had to go red, and the break was undone. Unit and repository tests run with vitest; browser tests run with Playwright (Chromium) against the running app with the test mocks. Nothing here was committed.

## 1. Long words may not wrap again (the word wrap rule inside a word is dropped) (statement R1)

- Break: in `src/components/FinnishLine.module.css`, `.keep .plain, .keep .word {   white-space: normal;   overflow-wrap: an` became ``
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "44 letter Finnish word wraps"`
- Result: RED, the test failed as it should

```
Error: a word runs past the right edge of its line
expect(received).toBe(expected) // Object.is equality
Expected: 0
Received: 1
test-results\redesign-lesson-phone-size-a9d87-t-375-px-a-plain-word-alone-chromium\test-failed-1.png
Error: a word runs past the right edge of its line
expect(received).toBe(expected) // Object.is equality
Expected: 0
Received: 1
test-results\redesign-lesson-phone-size-00cbe-75-px-a-tappable-word-alone-chromium\test-failed-1.png
```

## 2. The punctuation leaves the button again (a "?" can part from a wrapped word) (statement R2)

- Break: in `src/components/FinnishLine.tsx`, `{word.after && <span aria-hidden="true">{word.after}</span>}          ` became `</button>{word.after}`
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "tappable word in the middle with punctuation"`
- Result: RED, the test failed as it should

```
Error: a word runs past the right edge of its line
expect(received).toBe(expected) // Object.is equality
Expected: 0
Received: 1
test-results\redesign-lesson-phone-size-c16fc-the-middle-with-punctuation-chromium\test-failed-1.png
1 failed
```

## 3. The sheet goes back to the old way of finding its opener (statement R3)

- Break: in `src/components/SessionFrame.tsx`, `returnFocus={cross}` became ``
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "does not focus a button"`
- Result: RED, the test failed as it should

```
Error: after a tap on Keep going
expect(locator).toBeFocused() failed
Expected: focused
Received: inactive
14 × locator resolved to <button type="button" aria-haspopup="dialog" class="_leave_rtest_28" aria-label="Leave session">…</button>
- unexpected value "inactive"
test-results\redesign-lesson-the-lesson-9a049-tap-does-not-focus-a-button-chromium\test-failed-1.png
Error: expect(locator).toBeFocused() failed
Expected: focused
Received: inactive
```

## 4. A second press of Next line in Hear it counts again (statement R4)

- Break: in `src/screens/HearIt.tsx`, `if (!steady.accept(event)) return` became ``
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "double click on|two quick taps"`
- Result: RED, the test failed as it should

```
Error: expect(locator).toHaveText(expected) failed
Expected: "Line 2 of 3."
Received: "Line 3 of 3."
14 × locator resolved to <p role="status" tabindex="-1" data-tone="neutral" class="_status_1onxc_3 _neutral_1onxc_13 _hidden_1onxc_51">…</p>
- unexpected value "Line 3 of 3."
test-results\redesign-lesson-Hear-it-an-18e5d--later-click-moves-the-next-chromium\test-failed-1.png
Error: expect(locator).toHaveText(expected) failed
Expected: "Line 2 of 3."
Received: "Line 3 of 3."
14 × locator resolved to <p role="status" tabindex="-1" data-tone="neutral" class="_status_1onxc_3 _neutral_1onxc_13 _hidden_1onxc_51">…</p>
```

## 5. A second press of Next line in Say it counts again (statement R5)

- Break: in `src/screens/SayIt.tsx`, `if (!steady.accept(event)) return` became ``
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "in Say it moves one line"`
- Result: RED, the test failed as it should

```
Error: expect(locator).toHaveText(expected) failed
Expected: "Line 2 of 3."
Received: "Line 3 of 3."
14 × locator resolved to <p role="status" tabindex="-1" data-tone="neutral" class="_status_1onxc_3 _neutral_1onxc_13">…</p>
- unexpected value "Line 3 of 3."
test-results\redesign-lesson-the-speaki-bb35d--line-so-no-line-is-skipped-chromium\test-failed-1.png
1 failed
```

## 6. The helpers look only once for a sheet (they do not wait for the screen to settle) (statement R6)

- Break: in `e2e/session-helpers.ts`, `await expect(page.getByText('Loading speaking feedback.')).toHaveCount` became ``
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "by the helper"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBeGreaterThan(expected)
Expected: > 300
Received:   0
test-results\redesign-lesson-the-lesson-f9c54-heet-opens-after-the-screen-chromium\test-failed-1.png
1 failed
1 passed (5.4s)
```
