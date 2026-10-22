# Design review, job 2-smoke, round 1

Scope judged: the design system is not locked (job 4) and the owner chose plain browser defaults, so I did not judge visual design. I checked wording, the Finnish heading, the status line, keyboard and focus behaviour, the timeout, the README wording, and the banned styles and product rules.

## What I checked

- `src/App.tsx`: one `<main>`, one `<h1 lang="fi">Hei!</h1>`, one `<p role="status">`, and a native `<button type="button">` that only appears after a failure. No colour, font, gradient, badge, icon, emoji, mode picker, word list, streak or shaming wording. No banned style.
- `index.html`: `lang="en"`, title "PuhuScribe", viewport meta without a zoom lock. The Finnish heading is marked on the element itself, so screen readers pronounce "Hei!" correctly.
- Wording: all three messages are full sentences ending in a full stop. The failure message states the problem in passive voice ("Your visit was not saved."), blames nobody, and gives one next step with a matching button. Tone is kind and consistent.
- README "Database changes" and the changed Open line: no em dashes, no hype words, no "not X, but Y" framing, plain steps with consequences.

## Findings

1. Should fix. `src/App.tsx` lines 20 to 33. `AbortSignal.timeout()` is called inside the `try`. On a browser that lacks it (iOS Safari before 16, older Android WebViews, which newcomers often have on cheap or old phones), the call throws, the `catch` returns false, and the page always says "Your visit was not saved. Check your internet connection" and Try again fails the same way forever. Fix: build the timeout with `AbortController` and `setTimeout` (works everywhere), or feature detect it. This is a smoke page, but the same pattern will be copied into real screens.
2. Should fix. `src/App.tsx` lines 52 to 58 and 69 to 73. When the learner presses Try again, the button is removed from the page, so keyboard focus drops to the top of the document and a keyboard or screen reader user loses their place. The status line still announces, so they are not left in silence. Fix: after pressing Try again, move focus to the status line (give it `tabIndex={-1}` and focus it), or keep the button in the page but disabled while saving. Add a keyboard test (Tab to the button, press Enter, status shows "Saving your visit.").
3. Note. `src/App.tsx` line 13. "Check your internet connection" is also shown when the server answered 503, which is our side, not the learner's connection. It is not shaming, and the spec fixes this wording, so I leave it. Job 4 or the first real screen could use "Try again in a moment, and check your internet connection if it keeps failing."
4. Note. `src/App.tsx` line 17. The 10 second timeout is long enough for a slow phone connection, and the Worker gives up on the database at 3 seconds, so the page normally hears a failure well before 10 seconds. Two consequences to know: the learner sees "Saving your visit." with no change for up to 10 seconds on a dead connection, and a slow answer that arrives after the timeout may mean the visit was saved while the page says it was not, so Try again can add a second visit. Both are harmless for a practice counter. Keep this in mind for real screens where a duplicate save matters.
5. Note. `role="status"` is on the status line from the first render and its text changes, so changes are announced politely. The first "Saving your visit." is often not announced because it is present at load. That is acceptable. When Try again fails twice in a row, the line passes through "Saving your visit." so the repeat failure is still announced.
6. Note for job 4. Browser default buttons are about 20 to 24 px tall, under the 44 px tap target, and no dark mode is set. The browser's default focus ring is kept, which is correct. Job 4 must give the button a 44 px target and check contrast in light and dark mode.
7. Note. The "Hei!" heading and English messages mix languages on one screen. This is the intended practice page, shown only on the private preview link, with no learner flow, so I did not flag it.

## Must fix

None.

Result: pass
