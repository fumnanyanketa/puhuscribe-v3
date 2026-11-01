# Design review: 15-onboarding, round 1

Reviewer: design and learner experience, with the security checklist. Head `4d46b3c`, 1 November 2026.

Method: read the spec, `build.md`, `AGENTS.md`, `design.md` ("Welcome block", "Finnish line") and the full diff. I ran the app from the worktree with `npm run dev` on port 5233. The Worker answered `/api/today` itself (`{"signedIn":false,"ended":false}`), so no stand-in was needed. I took screenshots with Playwright in Chromium and WebKit at 375 x 812, light and dark, plus 375 x 667, 320 x 568, text at 200 percent, the Start focus ring, and the `/design-reference` "Welcome block" section. The Switzer font files are not in the checkout, so everything was measured with the fallback font (Poppins), as the build notes say. I copied no font files in. The dev server is stopped. The hallway test (statement 12) is the owner's and I did not judge it.

Screenshots: `factory/jobs/15-onboarding/evidence/design-review-screens/` in the worktree (26 files, named `<browser>-<scheme>-<size>-<what>.png`).

## What is good

- **It fits as promised.** At 375 x 812 the whole Start button ends at 709 px and the whole guest line at 784 px, in Chromium and WebKit, light and dark. Same numbers as the build notes. No sideways scroll at 375, 320 or with text at 200 percent.
- **It matches the locked design system.** Every colour, size and space is a token. Spoken band: `#e9f2f4` with the teal edge and the `#166270` label (6.1 to 1 light, 7.3 to 1 dark). Written label: `#6b46c1`, 5.5 to 1 at worst on the light page fade and 6.6 to 1 in dark. Body text is ink on the page or on the band. I read the computed styles on the page: they are the tokens, not near misses. It is the same look as the Spoken and Written parts of Hear it (`FinnishLine.module.css`).
- **Banned styles: none.** No accent bar (the band has the same 1 px edge as Hear it), no eyebrow, no pills or badges, no glow, gradient text, shadow, icon, emoji or picture. No Inter, Space Grotesk or Bricolage. No tile row, no card grid, no numbering. The welcome adds no card of its own on the front door.
- **Writing rules hold.** 73 words, plain sentences, no em dash, no hyphen as punctuation, no colon reveal, no "not X, but Y", no hype words, no group of three. No Finnish.
- **Screen reader order is right.** One `h1` ("Today's session"), the lead, a region named "Welcome to PuhuScribe" with an `h2`, the sentences, then the Start button, then the guest line, then "I already have an account" and the two links. Spoken and Written are read as a label and then its sentence, so colour is never the only sign. The first Tab stop is Start, and its focus ring is 3 px in the ink colour in both schemes (visible in the focused screenshots).
- **Nothing in it can be tapped,** so there are no new tap targets. Start is 54 px tall and 335 px wide.
- **The reference page shows it** in the phone's light or dark setting (the four `design-reference-welcome` screenshots), inside the same bordered card the other sections use.

## Findings

### Must fix

None.

### Should fix

1. **"forms" is used in two meanings in neighbouring sentences.** `src/screens/welcome-copy.ts` (`WELCOME_TWO_FORMS` and `WELCOME_WRITTEN`). "Every line comes in two forms" is followed by "How Finnish is written in books and on forms." A total beginner reading slowly can take the second "forms" as the same word, or as paperwork, and lose the thread. This is the owner's approved draft, so the owner decides.
   Fix: change the last words of the Written sentence, for example "How Finnish is written in books and on official papers." Keep "forms" only for the "two forms" idea. The word count stays under 80.

### Note

2. **On a small phone Start is below the first screen.** At 375 x 667 (an iPhone SE) only the top 12 px of Start is on screen and the guest line is hidden. At 320 x 568 Start begins at 679 px. Before this job Start was near the top of the page. The locked fit rule and the spec are 375 x 812 only, the page scrolls, and Start is the first Tab stop, so this passes. A cut off button does hint at scrolling. If the owner cares about the oldest phones, the cheapest fix is the one `design.md` already names: tighten the spacing first, then drop the closing sentence "Spoken comes first. The written form sits under it." (the bands already show that order).
3. **The builder's question: keep the Written part as plain text, not a second filled band.** In Hear it the written line has no wash, only the violet label, and the welcome should look like what the learner meets seconds later. A second fill would make the two read as two equal tabs to tap, which is the one thing this block must not look like, and there is no violet wash token (the lavender one is for gentle corrections and would mean something else). The 16 px indent of the Written part lines up with the text inside the band, which is what lets it read as "under" the Spoken band. If the hallway test shows people miss the Written part, try a heavier label before adding a fill.
4. **The Spoken band is a rounded filled box and might invite a tap.** Nothing happens on tap. In Hear it the words in the band are the tap targets, so a beginner may expect the same here. The hallway test is the place to see whether anyone tries. No change now.
5. **"You tap any word to see what it is"** (`WELCOME_SESSION`). "What it is" is vague for a beginner who has no word yet. "What it means" says more. Owner's approved text, so this is only a suggestion.
6. **The welcome heading comes third on the page** (after the wordmark, "Today's session" and the lead sentence). The `h1` and the lead existed before this job and read fine above the welcome. I leave the order as the owner approved it. If the hallway test shows people skip the block, a welcome first order is the thing to try.
7. **The `/design-reference` lead sentence says "front door".** It is a project word, but that page is for the owner and the team, not learners, so I left it.

## Banned list and product rules check

No mode picker, word list, streak, shaming correction, grammar lesson, rank, badge or milestone. The block explains the loop in two plain sentences and leads to Start. Fonts, colours and spacing are the project's own (Poppins and Switzer tokens, as the locked design system says). No banned layout or style from the owner's list.

## Security checklist

| Check | Result |
| --- | --- |
| No keys, tokens or passwords in code, logs or evidence | Pass. I scanned every added line of the diff for key shapes (`eyJ...`, `sb_secret_`, `sb_publishable_`, `sk-...`, `service_role`, `Bearer ...`, `postgres://`, any 40 character unbroken string). No match in code, tests, notes or the evidence files. I did not open any `.env*` file. |
| No learner data reaches the browser beyond before | Pass. The only data used is the existing `GET /api/today` answer (`signedIn`, `ended`). The welcome text is a constants file. No new field, request or route. |
| No new third party script, font host or package | Pass. `package.json` and `package-lock.json` are unchanged. No `http` address, `@import`, `url(` or font file in the changed source or CSS. |
| Nothing written to storage or cookies | Pass. No `localStorage`, `sessionStorage`, `document.cookie`, IndexedDB or cache use in `Welcome.tsx`, `welcome-copy.ts`, the CSS or the `FrontDoor.tsx` change. A test checks it at run time. |
| No change under `worker/`, `supabase/`, `wrangler.jsonc`, `package.json` or `src/privacy` | Pass. `git diff main...factory/15-onboarding --stat` over those paths is empty. The privacy notice and data inventory stay true, because nothing new is collected. |

## Result

Result: pass

One wording point (finding 1) is the owner's to decide at approval. Findings 2 to 7 are notes. The builder's question has an answer: keep Written unfilled.
