# Proof by breaking the new protections of round 3

Each protection of job 19-redesign was broken on purpose in the working copy, its test was run and had to go red, and the break was undone. Unit and repository tests run with vitest; browser tests run with Playwright (Chromium) against the running app with the test mocks. Nothing here was committed.

## 1. All five signs are shown whatever the room (statement R1)

- Break: in `src/screens/RoadScreen.tsx`, `const shown = fitSigns(view.signs, view.markerAt, signCount)` became `const shown = { signs: view.signs, markerAt: view.markerAt }`
- Command: `npx playwright test e2e/redesign-road.spec.ts --project=chromium --reporter=line -g "no two signs touch"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBe(expected) // Object.is equality
Expected: false
Received: true
test-results\redesign-road-small-phones-b5266-bar-the-card-scrolls-inside-chromium\test-failed-1.png
Error: expect(received).toBe(expected) // Object.is equality
Expected: false
Received: true
test-results\redesign-road-small-phones-06cfc-bar-the-card-scrolls-inside-chromium\test-failed-1.png
Error: expect(received).toBe(expected) // Object.is equality
Expected: false
```

## 2. Tall boards are not given room (the least gap between signs is dropped) (statement R2)

- Break: in `src/road/RoadPicture.tsx`, `signSpots(signs.length, lowest, 1, signGap)` became `signSpots(signs.length, lowest, 1, 0)`
- Command: `npx playwright test e2e/redesign-road.spec.ts --project=chromium --reporter=line -g "no two signs touch"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBe(expected) // Object.is equality
Expected: false
Received: true
test-results\redesign-road-small-phones-06cfc-bar-the-card-scrolls-inside-chromium\test-failed-1.png
Error: expect(received).toBe(expected) // Object.is equality
Expected: false
Received: true
test-results\redesign-road-small-phones-0fe05-bar-the-card-scrolls-inside-chromium\test-failed-1.png
Error: expect(received).toBe(expected) // Object.is equality
Expected: false
```

## 3. The card has no height cap (statement R3)

- Break: in `src/screens/RoadScreen.module.css`, `max-height: 42dvh;` became `max-height: none;`
- Command: `npx playwright test e2e/redesign-road.spec.ts --project=chromium --reporter=line -g "no two signs touch"`
- Result: RED, the test failed as it should

```
Error: expect(received).toEqual(expected) // deep equality
- Expected  - 2
+ Received  + 2
test-results\redesign-road-small-phones-b5266-bar-the-card-scrolls-inside-chromium\test-failed-1.png
Error: expect(received).toBe(expected) // Object.is equality
Expected: false
Received: true
test-results\redesign-road-small-phones-06cfc-bar-the-card-scrolls-inside-chromium\test-failed-1.png
Error: expect(received).toEqual(expected) // deep equality
- Expected  - 2
```

## 4. The fit leaves out the next sign (only the current one is kept) (statement R4)

- Break: in `src/lib/road-state.ts`, `if (markerAt + 1 < signs.length) kept.add(markerAt + 1)` became ``
- Command: `npx vitest run src/lib/road-state.test.ts -t "fewer signs"`
- Result: RED, the test failed as it should

```
❯ src/lib/road-state.test.ts (15 tests | 3 failed | 11 skipped) 20ms
× [redesign 20] keeps all five when there is room 14ms
× [redesign 20] always keeps the sign of the marker and the one after it, even with a count of one 2ms
× [redesign 20] adds the sign before the marker first, then the one after the next, and keeps the order 1ms
Test Files  1 failed (1)
Tests  3 failed | 1 passed | 11 skipped (15)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 3 ⎯⎯⎯⎯⎯⎯⎯
FAIL  src/lib/road-state.test.ts > fewer signs when the room is short > [redesign 20] keeps all five when there is room
AssertionError: expected { signs: [ 'a', 'b', 'c', 'e' ], …(1) } to deeply equal { …(2) }
- Expected
```

## 5. The text size probe is dropped, so a text size change is not noticed (statement R5)

- Break: in `src/screens/RoadScreen.tsx`, `if (textProbe.current) observer?.observe(textProbe.current)` became ``
- Command: `npx playwright test e2e/redesign-road.spec.ts --project=chromium --reporter=line -g "no two signs touch"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBe(expected) // Object.is equality
Expected: false
Received: true
test-results\redesign-road-small-phones-b5266-bar-the-card-scrolls-inside-chromium\test-failed-1.png
Error: expect(received).toBe(expected) // Object.is equality
Expected: false
Received: true
test-results\redesign-road-small-phones-9f4c4-bar-the-card-scrolls-inside-chromium\test-failed-1.png
2 failed
8 passed (25.8s)
```

## 6. Keep it draws its instruction twice again (statement R6)

- Break: in `src/screens/KeepIt.tsx`, `visuallyHidden={message === INSTRUCTION}` became `visuallyHidden={false}`
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "once to the eye"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBe(expected) // Object.is equality
Expected: 1
Received: 2
test-results\redesign-lesson-the-finish-822d8-rries-it-for-screen-readers-chromium\test-failed-1.png
1 failed
```

## 7. The crash screen draws its sentence under the title again (statement R7)

- Break: in `src/components/CrashBoundary.tsx`, `<StatusLine tone="problem" visuallyHidden>` became `<StatusLine tone="problem">`
- Command: `npx playwright test e2e/design-reference.spec.ts --project=chromium --reporter=line -g "crash screen"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBe(expected) // Object.is equality
Expected: 1
Received: 2
test-results\design-reference-the-crash-83f6a-nce-kept-for-screen-readers-chromium\test-failed-1.png
1 failed
```
