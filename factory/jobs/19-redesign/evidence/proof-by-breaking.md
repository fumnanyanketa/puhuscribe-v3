# Proof by breaking each protection

Each protection of job 19-redesign was broken on purpose in the working copy, its test was run and had to go red, and the break was undone. Unit and repository tests run with vitest; browser tests run with Playwright (Chromium) against the running app with the test mocks. Nothing here was committed.

## 1. A removed colour token of the old look comes back (statement 1)

- Break: in `src/styles/tokens.css`, `:root {` became `:root {   --color-ground-top: #f1f0f6;`
- Command: `npx vitest run tests/design-tokens.test.ts -t "gone from src"`
- Result: RED, the test failed as it should

```
❯ tests/design-tokens.test.ts (62 tests | 1 failed | 61 skipped) 102ms
× [redesign 1] the lilac ground, violet, teal and azure tokens are gone from src/, names and values 97ms
Test Files  1 failed (1)
Tests  1 failed | 61 skipped (62)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 1 ⎯⎯⎯⎯⎯⎯⎯
FAIL  tests/design-tokens.test.ts > design tokens > [redesign 1] the lilac ground, violet, teal and azure tokens are gone from src/, names and values
AssertionError: expected [ …(2) ] to deeply equal []
- Expected
+ Received
```

## 2. A role colour (changed word peach) is used outside its files (statement 2)

- Break: in `src/components/Button.module.css`, `.button {` became `.stray {   color: var(--color-changed-text); }  .button {`
- Command: `npx vitest run tests/design-tokens.test.ts -t "role tokens are used only"`
- Result: RED, the test failed as it should

```
❯ tests/design-tokens.test.ts (62 tests | 1 failed | 59 skipped) 154ms
× [redesign 2] the changed role tokens are used only in the files that may use them 56ms
Test Files  1 failed (1)
Tests  1 failed | 2 passed | 59 skipped (62)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 1 ⎯⎯⎯⎯⎯⎯⎯
FAIL  tests/design-tokens.test.ts > colour roles > [redesign 2] the changed role tokens are used only in the files that may use them
AssertionError: expected [ …(4) ] to deeply equal [ …(3) ]
- Expected
+ Received
```

## 3. A second gradient is added to a component (statement 3)

- Break: in `src/components/Button.module.css`, `.button {` became `.stray {   background: linear-gradient(var(--color-wash-top), var(--color-wash-bottom)); }`
- Command: `npx vitest run tests/design-css.test.ts -t "no CSS or component"`
- Result: RED, the test failed as it should

```
❯ tests/design-css.test.ts (43 tests | 1 failed | 42 skipped) 65ms
× [design 18] no CSS or component in src/ uses anything on the list 62ms
Test Files  1 failed (1)
Tests  1 failed | 42 skipped (43)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 1 ⎯⎯⎯⎯⎯⎯⎯
FAIL  tests/design-css.test.ts > banned look and CSS for old phones > [design 18] no CSS or component in src/ uses anything on the list
AssertionError: expected [ Array(1) ] to deeply equal []
- Expected
+ Received
```

## 4. A component sets its own font size (statement 5)

- Break: in `src/components/Button.module.css`, `.button {` became `.stray {   font-size: 11px; }  .button {`
- Command: `npx vitest run tests/design-tokens.test.ts -t "never sets a font size"`
- Result: RED, the test failed as it should

```
❯ tests/design-tokens.test.ts (62 tests | 1 failed | 61 skipped) 38ms
× [redesign 5] a component never sets a font size of its own: every size reads a text token 35ms
Test Files  1 failed (1)
Tests  1 failed | 61 skipped (62)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 1 ⎯⎯⎯⎯⎯⎯⎯
FAIL  tests/design-tokens.test.ts > type scale > [redesign 5] a component never sets a font size of its own: every size reads a text token
AssertionError: expected [ Array(1) ] to deeply equal []
- Expected
+ Received
```

## 5. Quiet text is made too pale for its contrast floor (statement 6)

- Break: in `src/styles/tokens.css`, `--color-text-quiet: #556863;` became `--color-text-quiet: #98a8a3;`
- Command: `npx vitest run tests/design-tokens.test.ts -t "reaches"`
- Result: RED, the test failed as it should

```
❯ tests/design-tokens.test.ts (62 tests | 7 failed | 15 skipped) 22ms
× [design 4] [redesign 6] quieter text in a sheet reaches 4.5:1 5ms
× [design 4] [redesign 6] quieter text on a panel reaches 4.5:1 1ms
× [design 4] [redesign 6] quieter text on the mint end of the wash reaches 4.5:1 1ms
× [design 4] [redesign 6] quieter text in the middle of the wash reaches 4.5:1 0ms
× [design 4] [redesign 6] quieter text on the peach end of the wash reaches 4.5:1 0ms
× [design 4] [redesign 6] quieter text on a soft mint fill reaches 4.5:1 1ms
× [design 4] [redesign 6] quieter text on the slate tile reaches 4.5:1 1ms
Test Files  1 failed (1)
Tests  7 failed | 40 passed | 15 skipped (62)
```

## 6. The road card quotes an app path instead of the constant (statement 45)

- Break: in `src/road/RoadCard.tsx`, `href={PATHS.signIn}` became `href={'/sign-in'}`
- Command: `npx vitest run tests/redesign-rules.test.ts -t "quoted app path"`
- Result: RED, the test failed as it should

```
❯ tests/redesign-rules.test.ts (7 tests | 1 failed | 6 skipped) 17ms
× [redesign 45] the files this job adds hold no quoted app path 15ms
Test Files  1 failed (1)
Tests  1 failed | 6 skipped (7)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 1 ⎯⎯⎯⎯⎯⎯⎯
FAIL  tests/redesign-rules.test.ts > paths > [redesign 45] the files this job adds hold no quoted app path
AssertionError: expected [ 'src/road/RoadCard.tsx' ] to deeply equal []
- Expected
+ Received
```

## 7. The road screen imports the test fixture of stops (statement 19)

- Break: in `src/screens/RoadScreen.tsx`, `import { useCallback` became `import '../road/road-fixture.ts' import { useCallback`
- Command: `npx vitest run tests/redesign-rules.test.ts -t "fixture|loadRoad"`
- Result: RED, the test failed as it should

```
❯ tests/redesign-rules.test.ts (7 tests | 2 failed | 5 skipped) 25ms
× [redesign 19] is imported only by tests and the reference page, never by a screen a learner sees 17ms
× [redesign 19] the road screen reads stops only through loadRoad() 4ms
Test Files  1 failed (1)
Tests  2 failed | 5 skipped (7)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 2 ⎯⎯⎯⎯⎯⎯⎯
FAIL  tests/redesign-rules.test.ts > the road fixture > [redesign 19] is imported only by tests and the reference page, never by a screen a learner sees
AssertionError: expected false to be true // Object.is equality
- Expected
+ Received
```

## 8. The road stores something on the phone (statement 44)

- Break: in `src/lib/road-data.ts`, `export` became `localStorage.setItem('road', 'x') export`
- Command: `npx vitest run tests/redesign-rules.test.ts -t "never stores anything"`
- Result: RED, the test failed as it should

```
❯ tests/redesign-rules.test.ts (7 tests | 1 failed | 6 skipped) 20ms
× [redesign 44] the road never stores anything on the phone 17ms
Test Files  1 failed (1)
Tests  1 failed | 6 skipped (7)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 1 ⎯⎯⎯⎯⎯⎯⎯
FAIL  tests/redesign-rules.test.ts > what the road must not hold > [redesign 44] the road never stores anything on the phone
AssertionError: src/lib/road-data.ts: expected 'import { callApi, isRecord } from \'.…' not to match /localStorage|sessionStorage|indexedDB…/
- Expected:
+ Received:
```

## 9. The speaking consent wording changes and its version label does not (statement 29)

- Break: in `src/lib/voice-consent.ts`, `'PuhuScribe keeps the text the service heard` became `'PuhuScribe keeps the words the service heard`
- Command: `npx vitest run src/screens/protected-copy.test.ts src/lib/voice-consent.test.ts -t "word for word|version"`
- Result: RED, the test failed as it should

```
❯ src/lib/voice-consent.test.ts (4 tests | 1 failed | 3 skipped) 46ms
× [speak 2] has a version label that changes whenever the text changes 43ms
❯ src/screens/protected-copy.test.ts (6 tests | 1 failed | 1 skipped) 31ms
× [redesign 43] [redesign 29] the whole speaking consent text is word for word, with its version label 22ms
Test Files  2 failed (2)
Tests  2 failed | 4 passed | 4 skipped (10)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 2 ⎯⎯⎯⎯⎯⎯⎯
FAIL  src/lib/voice-consent.test.ts > the voice consent text > [speak 2] has a version label that changes whenever the text changes
AssertionError: expected 'b126102b872f146de7a09567dff6816c9c9ea…' to be 'a09e4ccaeaa7d74ff542be8cad2c28d250cd9…' // Object.is equality
Expected: "a09e4ccaeaa7d74ff542be8cad2c28d250cd90489ada91b21bbc4eb670b2b440"
```

## 10. The delete warning is softened (statement 38)

- Break: in `src/screens/DeletePage.tsx`, `It cannot be undone.` became `It can be undone.`
- Command: `npx vitest run src/screens/protected-copy.test.ts -t "delete warning"`
- Result: RED, the test failed as it should

```
❯ src/screens/protected-copy.test.ts (6 tests | 1 failed | 5 skipped) 17ms
× [redesign 43] [redesign 38] the delete warning is word for word 13ms
Test Files  1 failed (1)
Tests  1 failed | 5 skipped (6)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 1 ⎯⎯⎯⎯⎯⎯⎯
FAIL  src/screens/protected-copy.test.ts > protected copy > [redesign 43] [redesign 38] the delete warning is word for word
AssertionError: expected 'This deletes your account and everyth…' to be 'This deletes your account and everyth…' // Object.is equality
Expected: "This deletes your account and everything saved with it, including your progress and any recordings. It cannot be undone. Download your data first if you want a copy."
Received: "This deletes your account and everything saved with it, including your progress and any recordings. It can be undone. Download your data first if you want a copy."
```

## 11. The old privacy claim "Never your name" comes back (statement 39)

- Break: in `src/privacy/first-layer.ts`, `We never ask for your name.` became `Never your name.`
- Command: `npx vitest run src/privacy/first-layer.test.ts -t "never ask for your name|old one|reworded"`
- Result: RED, the test failed as it should

```
❯ src/privacy/first-layer.test.ts (11 tests | 1 failed | 8 skipped) 21ms
× [redesign 39] a claim the inventory does not support is not in the first layer: the drawn "Never your name" and "Checked, then deleted" are reworded 12ms
Test Files  1 failed (1)
Tests  1 failed | 2 passed | 8 skipped (11)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 1 ⎯⎯⎯⎯⎯⎯⎯
FAIL  src/privacy/first-layer.test.ts > the first layer of the privacy notice > [redesign 39] a claim the inventory does not support is not in the first layer: the drawn "Never your name" and "Checked
AssertionError: expected 'Your progress, your settings, and a r…' not to match /Never your name/
- Expected:
+ Received:
```

## 12. Every session counts as the first lesson (statement 25)

- Break: in `worker/session-plan.ts`, `if (pick.open) return pick.sessions.length === 1 && pick.open.step ===` became `return true`
- Command: `npx vitest run worker/lesson-facts.test.ts -t "redesign 25"`
- Result: RED, the test failed as it should

```
❯ worker/lesson-facts.test.ts (9 tests | 2 failed | 5 skipped) 196ms
× [redesign 25] is gone once Hear it is finished 34ms
× [redesign 25] is absent on the second session 16ms
Test Files  1 failed (1)
Tests  2 failed | 2 passed | 5 skipped (9)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 2 ⎯⎯⎯⎯⎯⎯⎯
FAIL  worker/lesson-facts.test.ts > the first lesson field > [redesign 25] is gone once Hear it is finished
AssertionError: expected true to be undefined
- Expected:
+ Received:
```

## 13. A new word chip may load audio from another address (statement 33)

- Break: in `src/screens/new-words.ts`, `const AUDIO_PATH = /^\/audio\/[A-Za-z0-9][A-Za-z0-9._%/-]*$/` became `const AUDIO_PATH = /^.*$/`
- Command: `npx vitest run src/screens/new-words.test.ts -t "audio address outside"`
- Result: RED, the test failed as it should

```
❯ src/screens/new-words.test.ts (5 tests | 1 failed | 4 skipped) 22ms
× [redesign 33] [security] an audio address outside /audio/ on this address is refused, so no file loads from elsewhere 19ms
Test Files  1 failed (1)
Tests  1 failed | 4 skipped (5)
⎯⎯⎯⎯⎯⎯⎯ Failed Tests 1 ⎯⎯⎯⎯⎯⎯⎯
FAIL  src/screens/new-words.test.ts > the new words of the complete answer > [redesign 33] [security] an audio address outside /audio/ on this address is refused, so no file loads from elsewhere
AssertionError: https://example.com/a.mp3: expected [ { …(3) } ] to deeply equal []
- Expected
+ Received
```

## 14. The speaking sheet asks for the microphone before consent (statement 29)

- Break: in `src/screens/SayIt.tsx`, `firstLoad.current ??= loadVoice()` became `firstLoad.current ??= loadVoice()     void navigator.mediaDevices?.getUserMedia?.({ audio:`
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "redesign 29\] shows only"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBe(expected) // Object.is equality
Expected: 0
Received: 2
test-results\redesign-lesson-the-speaki-3e5a9-x-and-no-microphone-request-chromium\test-failed-1.png
1 failed
```

## 15. The delete page deletes before the second press (statement 38)

- Break: in `src/screens/DeletePage.tsx`, `void firstLook.current.then((next) => {       if (active) setView(next` became `void firstLook.current.then((next) => {       if (next === 'confirm') void callApi('/api/a`
- Command: `npx playwright test e2e/redesign-pages.spec.ts --project=chromium --reporter=line -g "redesign 38\] the delete page"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBe(expected) // Object.is equality
Expected: 0
Received: 2
test-results\redesign-pages-delete-feed-fd960-ted-before-the-second-press-chromium\test-failed-1.png
1 failed
```

## 16. The first lesson tip shows on every lesson (statement 25)

- Break: in `src/screens/HearIt.tsx`, `useState(session.firstLesson === true)` became `useState(true)`
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "redesign 25"`
- Result: RED, the test failed as it should

```
Error: expect(locator).toHaveCount(expected) failed
Expected: 0
Received: 1
14 × locator resolved to 1 element
- unexpected value "1"
test-results\redesign-lesson-the-tip-on-bd295--the-lit-card-opens-over-it-chromium\test-failed-1.png
1 failed
2 passed (12.0s)
```

## 17. Loading the road makes a guest account (statement 16)

- Break: in `src/screens/RoadScreen.tsx`, `useEffect(() => {` became `useEffect(() => {     void callApi('/api/guest', 'POST')`
- Command: `npx playwright test e2e/redesign-road.spec.ts --project=chromium --reporter=line -g "redesign 16"`
- Result: RED, the test failed as it should

```
Error: expect(received).toBe(expected) // Object.is equality
Expected: 0
Received: 4
test-results\redesign-road-the-home-scr-31fba-est-before-Start-is-pressed-chromium\test-failed-1.png
1 failed
```

## 18. The cross leaves the lesson without asking (statement 22)

- Break: in `src/components/SessionFrame.tsx`, `setLeaving(true)` became `window.location.assign(leaveHref)`
- Command: `npx playwright test e2e/redesign-lesson.spec.ts --project=chromium --reporter=line -g "redesign 22"`
- Result: RED, the test failed as it should

```
Error: expect(locator).toBeVisible() failed
Expected: visible
Error: element(s) not found
test-results\redesign-lesson-the-lesson-5a9b6-ves-focus-back-to-the-cross-chromium\test-failed-1.png
Error: expect(locator).toBeVisible() failed
Expected: visible
Error: element(s) not found
test-results\redesign-lesson-the-lesson-c2801--and-Leave-goes-to-the-road-chromium\test-failed-1.png
2 failed
1 passed (18.1s)
```
