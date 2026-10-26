# Design review, job 11-accounts

Judged from code, CSS and the spec's wording. No browser run. The design system is locked (`design.md`); screens use tokens, Button, StatusLine, Wordmark and the new TextField in v2's input style. No banned styles found (no accent bars, eyebrows, glow, emoji, banned fonts, streaks, counts, mode picker). Spec wording matches for the front door links, three account states, add email and code screens, guest warning, sign in text, delete confirmation and the gentle errors.

## Findings

1. Should fix. `src/screens/PrivacyPage.tsx` (Item, lists at "What we keep" and processors) with `src/screens/Account.module.css` `.list`. Cards (`li.item`) sit in a `ul` that keeps bullet markers and left padding, so each card shows a stray dot beside it and is pushed in. Fix: give a card list its own class with `list-style: none; padding: 0`, keep `.list` for the plain bullet lists (rights).
2. Should fix. `src/screens/PrivacyPage.tsx` contact link, `.link` in `Account.module.css`. A long contact address or web address (no spaces) cannot wrap and can scroll sideways at 320 px or 200 percent text. `.inlineLink` has `overflow-wrap: anywhere` but is unused. Fix: add `overflow-wrap: anywhere` to `.link`, or use `.inlineLink` for the contact.
3. Note. `AccountPage.tsx`, load failure view. Shows "try again" with no retry control; the learner must reload. Fix if cheap: add a quiet "Try again" button.
4. Note. `EmailFlow.tsx`, warn step. "Sign in anyway" is the primary button above "Go back", for a step that deletes progress. Spec wording is followed, so keep; consider making "Go back" the primary.
5. Note. `PrivacyPage.tsx` missing state: "PuhuScribe is not open to learners until they are." speaks to the owner, not the learner. Fine while the owner input is missing (must be replaced before launch by owner's call 2); the problem style is correct.
6. Note. `EmailFlow.tsx`, sign in code screen has three stacked paragraphs and no "Enter the code" sentence; the field label "6 digit code" carries it. Acceptable, matches statement 10.

Focus states come from the global `:focus-visible` rule and TextField's own outline; targets use `--tap-min`; fields have visible labels and 16 px text; focus moves to the field on each step.

Result: pass
