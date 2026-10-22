# Design and wording review: 13-review-site

Reviewer: design review, 22 October 2026. Branch `factory/13-review-site`, head `6d30b7e`, draft PR 19.

I built the site with `npm run build:review-site` and opened `dist-review/index.html` in Chromium at 375 px and 1280 px, light and dark. I read the diff, `spec.md`, `build.md`, the docs the job touched, the Worker's 403, 404 and 405 text and the tests. I wrote no code.

The design system is locked (`design.md` exists), but the spec tells the index page to borrow the review page's own system fonts and colours. It does: the colours (`#faf9fc`, `#ffffff`, `#1b1a20`, `#56525e`, `#1f42ac`) and the font stack match the review page from job 7.

## What I checked and found good

- **Index page, 375 px and 1280 px.** No sideways scroll (scroll width equals client width in both). One heading, two plain sentences, one card per dialogue, one row per round. Long text wraps (`overflow-wrap: anywhere`).
- **Banned styles.** None found. No eyebrow, no accent bar, no pill or badge, no gradient or glow, no icon or emoji, no Inter, Space Grotesk or Bricolage Grotesque. The font stack is system fonts only, so there is no Switzer or Poppins licence issue and nothing is loaded from the network. The card has a soft shadow and rounded corners, which is not on the banned list.
- **Status wording.** "Waiting for your review", "Review received" and "Not reviewed" are used exactly. "Waiting for your review" is bold, so it is not shown by colour alone.
- **Keyboard and contrast.** Links have a 3 px focus outline, an underline and a 44 px minimum height (10 px padding plus a 24 px line). Contrast is high: the link `#1f42ac` on white and the grey `#56525e` on `#faf9fc` both pass AA comfortably. The page has `lang="en"`, an `h1`, and each card is labelled by its heading.
- **Light and dark.** The page forces `color-scheme: light`, as the review page does. Dark mode looks identical to light, so nothing breaks in dark mode. This is consistent between the two pages, so I do not count it as a defect (see note 1).
- **Worker text pages.** The 403, 404 and 405 answers are one plain English line each as `text/plain`, with no file list and no stack detail. If the Access lock were missing, a reviewer would see "This site is private. Sign in through its Cloudflare Access page to open it." Plain and not alarming.
- **Docs against the writing rules.** I found no em dash or en dash in the added lines of `docs/content-pipeline.md`, `docs/conventions.md`, README or `.env.example`. I found no hype words, no "not X, but Y" framing and no colon reveals. The "Review site settings" table is real tabular data. The README table is re-aligned by Prettier, which is why the whole table shows as changed.
- **Tests.** The tests I could check carry `[site N]`. Two `it.each` calls (`handler.test.ts` line 240, `build.test.ts` line 197) carry the label in the test name on the next line. No test was removed or weakened (the diff removes no test lines; the only removed lines are the ESLint ignore, one tsconfig include and the old README table). I found no TODO, FIXME or placeholder in the job's files.

## Findings

### Should fix

1. **`factory/jobs/13-review-site/build.md`, "What waits for the owner", steps 1 to 8.** These are written for the manager, not for the owner. The owner has no engineering background, and the steps use "AUD tag", "Service Auth policy", "Workers Routes edit" and `gh secret set` without saying who does what. Fix: add a short owner section above the manager steps. It should say that the owner only has to (a) say which of their emails goes in the policy, (b) give the reviewer's email, (c) decide on any payment card prompt for the $0 plan, and (d) open the site once in a private window. Everything else is the manager's, done in the browser pane. Name each Zero Trust screen the way the dashboard labels it.
2. **`build.md` step 3.** It says to "copy its client ID and secret straight into GitHub". It does not say that Cloudflare shows the client secret only once. Fix: add that sentence, because a missed secret means making a new token.
3. **`build.md`, no message for the reviewer.** The reviewer's first contact is Cloudflare's sign-in page, not this site. Nothing tells the owner what to write to them. Fix: add a short draft message (link, "you will get an email with a code from Cloudflare, enter it, the code expires after a few minutes, check spam", and how to send the file back) in plain English for the owner to send. This is the step where a total beginner is most likely to give up.
4. **`review-site/handler.ts` lines 116 and 120 (the 404 answers).** A reviewer who mistypes or follows an old link gets "Not found." and nothing else, with no way back. Fix: for the 404 only, say "Not found. Go to the start page of this site." (a plain text page cannot hold a link, so name the address `/` in words), or return a small HTML page with one link to `/`. Keep the headers.
5. **`scripts/review-site/build.ts` `indexHtml`, link text.** Every round link reads only "Round 1", "Round 2". With two dialogues, a screen reader's link list holds two links called "Round 1". Fix: add `aria-describedby` pointing at the dialogue heading, or put a visually hidden dialogue title inside the link. Do not change the visible text.

### Notes

1. **Dark mode.** Both the index and the review page stay light on a phone set to dark. This matches job 7 and the spec, and it is readable. If the owner wants dark support later, change both pages together.
2. **`indexHtml`, empty and finished states.** With an empty list, the index says "Nothing is waiting for your review right now." When every round is "Review received" there is no sentence saying so, and the intro still tells the reviewer to open a waiting round that does not exist. Consider one line, "Nothing is waiting for you at the moment.", shown when no round is waiting.
3. **`indexHtml`, slug line.** "Dialogue: meeting-people-new-colleague" is developer text next to the English title. The spec asks for it, so I leave it. A non-technical reviewer can ignore it, but it adds clutter. Consider dropping it in a later job.
4. **Round order.** The index lists rounds oldest first. When round 3 exists, the one that matters is at the bottom, next to two "Review received" rows. It is still bold, so it is findable. Newest first would put it at the top. Optional.
5. **The review page has no link back to the index.** The reviewer must use the browser's back button. The title is "Review round 1" with no dialogue name. This is job 7's page and the spec says it stays byte for byte, so I leave it, but a later job could add a link back.
6. **`ul` with `list-style: none`.** Safari with VoiceOver drops the list meaning from such lists. Add `role="list"` on the `ul` if this matters. Very small.
7. **Docs wording.** `docs/content-pipeline.md` line 38 reads "Built in job 13-review-site; the decision is in [...]". It points to a spec anchor (`#decision`), which exists. Fine. The sentence "Until the four deploy settings exist, the deploy job skips the deploy with a notice" is accurate but the four are not named in the same paragraph. Say "the two secrets and two variables for deploying" if you edit the file again.
8. **Evidence.** The builder's index screenshots (`evidence/local-4-index-375-chromium.png` and the WebKit one) sit in the main checkout's evidence folder, not in the worktree. I did not open them. I judged from my own screenshots.

## Result

No must-fix findings. Five should-fix findings, all wording or owner guidance, none in the layout.

Result: pass
