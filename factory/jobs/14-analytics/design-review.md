# Design review: 14-analytics, round 1

Reviewer: design and learner experience. Head `5715f92`, 30 October 2026.

Method: read the spec, `build.md`, `AGENTS.md`, `design.md` use through the shared components, and the full diff of `OwnerPage.tsx`, `FeedbackPage.tsx`, `CrashBoundary.tsx`, the three "Send feedback" links, `PrivacyPage.tsx`, `data-inventory.ts`, `processors.ts` and the new CSS. This Windows machine has no local database, so I did not run the app. I judged layout and contrast from the CSS (every colour, size and space is a token, no hex values, no new fonts) and relied on the green CI run for the 320 px, 200 percent, 44 px, keyboard and axe tests. No screenshots were taken.

## What is good

- Every button is the shared `Button` (explicit token colours), every new colour and size comes from `tokens.css`, fonts are the project fonts, no accent bars, no eyebrows, no pills, no glow, no icons.
- The owner page's five numbers are a plain stacked list (title, value, goal, one sentence), not a tile row. It reads clearly at phone width. Visits are real tables with captions and row headers, newest day first. Long text uses `overflow-wrap: anywhere` and `white-space: pre-wrap`, and learner text is rendered as text.
- The feedback form has a visible label, a count tied to the box with `aria-describedby`, 16 px text, a focus ring and gentle wording for every learner side message.
- The "Send feedback" links are quiet, 44 px tall and sit outside the loop. The front door link only appears once the device has an account.
- No em dashes, no hyphens as punctuation and no hype words in the new text.

## Findings

### Must fix

1. **The privacy notice's "How long we keep it" is now false for the two new items.** `src/privacy/data-inventory.ts:12` (`HOW_LONG`) says everything is kept "Until you delete your account", that it applies "for every item below", and that deleting the account "deletes everything at once". `RIGHTS` in `PrivacyPage.tsx` says the same. The visit count and crash reports are not linked to an account, so deleting an account does not delete them, and crash reports go after 30 days. The visit count's own line, "Kept as daily totals", gives no length of time at all.
   Fix: add one sentence to `HOW_LONG` and the rights text, for example "The visit count and crash reports are not linked to your account, so deleting your account does not change them. Crash reports are deleted after 30 days." Give the visit totals a real answer (a period, or "kept without an end date, as totals with no personal data"). The owner decides the wording.

### Should fix

2. **Crash reports overclaim: "nothing you typed or said is included."** `data-inventory.ts` (Crash reports, `what`) and the privacy test. The cleaning is best effort: it removes text typed into fields that are on the page, emails, token shapes and long digit runs from the error message. It cannot know every string an error message might carry, and a spoken transcript shown on screen is not a field. The absolute sentence promises more than the code can prove.
   Fix: say what is done, for example "We remove anything you typed or said from the error text before saving it, and we do not link a report to you." The owner may choose to keep the stronger line, but should do so knowingly.
3. **"Owner page access" sits in the learner's notice under the wrong lead in and with the wrong legal reason.** `data-inventory.ts` (the `private.owners` item) is listed under "Your learning progress:" and its legal reason is "Needed to provide the service you asked for". A learner never asked for it and has no row. A beginner reading "Only for the app's owner" under their own progress will wonder if it applies to them.
   Fix: keep the line (the download lists it) but give it its own short lead in such as "Only for the app's owner:", with a plain legal reason (legitimate interest in keeping the owner's page private), or tell the owner this is a choice. Also rename the lead in "Your learning progress:" to "Your learning and what you send us:", since feedback is not progress.
4. **The visit count line says "which we do not keep" about the internet address, but Cloudflare handles that address.** `data-inventory.ts` (Visit count). The Cloudflare entry says requests pass through it, so the claim is true for PuhuScribe's database and false as a general statement.
   Fix: "PuhuScribe's database does not keep it" or add "Cloudflare, which runs the app, sees it as it passes the request on (see below)".
5. **The crash screen is a dead end for a beginner.** `src/components/CrashBoundary.tsx`. It shows one sentence and Reload. If the same screen breaks again, Reload loops, and there is no way back to the start, no page heading, and no wordmark. Focus is lost when the screen is replaced, so a screen reader user gets nothing announced.
   Fix: add a quiet "Back to the start" link under Reload (the app's usual wording), give the page an `h1` or move focus to the status line on mount (it accepts a `ref` and has `tabIndex={-1}`), and keep the spec's sentence and button as they are.
6. **A signed in account that is not the owner is stuck.** `OwnerPage.tsx` (`not_owner`). It shows "This account cannot open the owner page." with no action. On the owner host every other page redirects to `/owner`, so there is no sign out button anywhere. Someone who typed the wrong email must clear cookies.
   Fix: under the line, add a "Sign out" quiet button that calls `/api/sign-out` and reloads, so the owner can try the right email.
7. **After sending feedback the form disappears and focus is lost.** `FeedbackPage.tsx` (`view === 'sent'`). The focused Send button is removed and the "Thank you" status line is mounted already holding its text, which many screen readers do not announce. Keyboard users start again from the top.
   Fix: focus the status line when the view becomes `sent` (use its `ref`). Same for the `none` text if reached after a 401.
8. **Two owner page sentences are hard to read, and one goal is ambiguous.** `OwnerPage.tsx`.
   - Day 7 retention: "Learners whose first session was on a day whose day 7 has passed in the last 30 days, and how many of them started a session exactly 7 days later." Try: "Of the learners who first started 7 or more days ago (within the last 30 days), how many came back to start a session exactly 7 days after their first."
   - Cost: "PRD target: under €0.75 a month." The value is a 30 day total and a per learner figure in dollars. Say "Target: under €0.75 per learner a month (about $0.80)" or at least "per active learner", and spell out PRD or drop it.
   - The empty states read oddly: "No learner has reached day 7 yet (0 of 0 learners)" and "$0.00 in total, none per active learner". Drop the "(0 of 0 ...)" and write "no learners yet" for the empty per learner amount.
9. **The "no account" link says "Go to the front door".** `FeedbackPage.tsx:161`. "Front door" is a project word. Every other screen says "Back to the start".
   Fix: "Back to the start".

### Note

10. `medianText` writes "1 minutes" when the median is 1. Use "1 minute".
11. `OwnerPage.tsx` list keys: feedback uses created time plus index, crashes use name plus last seen time. Two crash groups with the same name and time would collide. Use an id or add the path.
12. The scrolling table boxes (`Owner.module.css` `.tableBox`) are not keyboard focusable. They only scroll if text is very large, and the CI run at 320 px and 200 percent passed, so this is low risk. If it ever scrolls, add `tabIndex={0}`, `role="region"` and a label.
13. A pasted message over 1,000 characters is cut silently by `maxLength`, so the "Please keep your message to 1,000 characters." line can never show before sending. Acceptable, but the count then stops at 1,000 without telling the learner something was cut.
14. The intro line "what worked, what did not, or what broke" is a group of three. It is the spec's exact text, so leave it unless the owner wants it changed.
15. On the owner host the sign in screen is the learner's (it talks about keeping progress). It is only seen by the owner, so I did not count it, but check it reads sensibly at go live.
16. Rights section: the notice does not say what happens if someone asks to have their visit or crash data removed (it cannot be found, because it is not linked to anyone). One sentence would answer the question before a learner asks.

## Banned list check

No accent bars, eyebrows, pills or badges, glow, gradient text, emoji or icons, identical card grids or banned fonts. The owner page numbers are the point of that page and read as a list, not tiles. The feedback and crash lists use the shared bordered card (`Account.module.css` `.item`) stacked one per line, which is the existing pattern in the privacy notice.

## Product rules check

No mode picker, word list, streak or grammar lesson. Feedback is a quiet link outside the loop. Learner side wording is gentle. The owner page shows nothing back to learners.

Result: changes needed

## Round 2, 30 October 2026

Scope: only the four items asked for (must fix 1, should fix 2, 3 and 4), against `git diff 5715f92..5df704c`. The other round 1 findings are on `factory/todo.md` and were not checked.

### Is each item fixed

1. **Must fix 1, "How long we keep it" and the rights line: fixed.** `HOW_LONG` now says data linked to the account goes with the account, that the visit count and crash reports are not linked so account deletion does not change them, that crash reports go after 30 days, and that the visit count is kept as daily totals. I checked each claim against the code: `private.crash_reports` has a 30 day delete (migration line 334), the visit tallies have no deletion job and no user column, and feedback and the owner row cascade on account deletion. The rights list now says "deletes everything linked to your account at once", and `NOT_LINKED_RIGHTS` adds one honest sentence after the list ("we cannot find it, and we will tell you so"). That also closes round 1 note 16.
2. **Should fix 2, crash report line: fixed.** "Nothing you typed or said" is gone. The new text says what is done and matches `crash-reporter.ts` (text typed into `input` and `textarea` fields is removed from the message) and `crash-clean.ts` (email shapes, ids, token shapes of 32 or more characters, digit runs of 6 or more, ids in the path), run in the browser and again in the Worker.
3. **Should fix 3, "Owner page access": fixed.** It has its own lead in, "Only for the app's owner:", a plain legal reason (legitimate interest in keeping the owner page private), and a "how long" that matches the README's delete statement and the cascade. The learner lead in is now "Your learning and what you send us:". The download keeps the same table order.
4. **Should fix 4, visit count and the internet address: fixed.** It now says Cloudflare, which runs the app, sees the address because it delivers the page, and PuhuScribe's database does not keep it. `worker/visits.ts` passes on the country only, so this is true.

### Does the new wording claim only what the code does

Yes, with one small point (note A below). No sentence promises more than I could find in the code.

### Writing rules

No em dashes, no hyphens used as punctuation, no colon reveals (the only colons are the existing lead ins that introduce a list), no "not X, but Y", no hype words. The one list of four ("an email address, an id, a sign in token or a long number") is a factual list of what is removed, not a rhetorical group of three. Words are plain. The `HOW_LONG` paragraph is six sentences, which is long but reads in order and each sentence says one thing.

### Notes

- **A. "any text typed into a box on the screen" is slightly wide.** `typedValues()` only reads `input` and `textarea` fields that are on the page when the error happens, and `withoutValues` skips values shorter than 2 characters. A one letter entry, or text in anything that is not a field, is not removed by this step (the shape cleaning still applies). Suggested wording if the owner wants it exact: "any text typed into a field on the screen". Not blocking.
- **B. Rights line says the data "cannot be linked to you".** True for the account (no user column). Because the cleaning is best effort, a report could in rare cases carry a stray piece of personal text in its message. The sentence is still fair, since the owner could not tell whose it is, but it is a firm claim.

### For the owner to look at when approving the wording

1. `HOW_LONG`: "The visit count is kept as daily totals with no personal data for as long as the service runs." This is a decision to keep the totals with no limit. The builder offers a limit (for example 25 months) as a small migration if wanted.
2. `NOT_LINKED_RIGHTS`: "If you ask to see or delete your part of them, we cannot find it, and we will tell you so." This is a promise about how requests are answered.
3. Crash reports "what": the list of what is removed, and note A above.
4. Visit count "what": names Cloudflare as seeing the address. Check that the Cloudflare entry in the same notice agrees.
5. The learner lead in rename ("Your learning and what you send us:") was not on the manager's list; it is one line and easy to undo.

Round 2 result: all four items fixed, no new must fix or should fix found.

Result: pass
