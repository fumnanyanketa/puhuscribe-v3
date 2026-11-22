# signup-choice: build notes

Fast route, owner decision 22 November 2026. Branch `factory/signup-choice`. Pull request https://github.com/fumnanyanketa/puhuscribe-v3/pull/58, merged as `97ce9c2` and deployed to meetaleksi.com the same day with the Live workflow's `app` task (run 45018627377), on the owner's words "Merge it and deploy so I can create my account". The spec and the owner's choices are in `spec.md`.

## What I built

- **Aleksi's stop screen** (`src/road/StopScreen.tsx`, `StopScreen.module.css`): a visitor with no account sees the mint "Create an account" and the white "Continue as guest", equally tall, then "Already have an account? Sign in" and the guest line with the privacy link. Everyone else keeps one Continue.
- **Start** (`src/screens/RoadScreen.tsx`): `start('account')` makes the guest through the same `/api/guest` Turnstile step, then opens `/learn/account/email?then=lesson` (`ACCOUNT_BEFORE_LESSON` in `src/lib/app-paths.ts`). A second press while one is working does nothing.
- **"Create your account"** (`src/screens/EmailFlow.tsx`): with exactly `?then=lesson` the back arrow goes to the road, there is no progress warning, and after the code it says "Your account is ready." (or "You are signed in to your account.") and Continue opens the lesson.
- **Shorter text** (owner's choice "One line + short warning"): "We’ll email you a 6 digit code." and, only from the account page, "If this email already has an account, your guest progress on this phone is replaced." The sign in screen keeps its old line (`SIGN_IN_SENDS_CODE`).
- **Send error**: a server failure says "We couldn’t send the code right now. Please try again in a few minutes."; only a network failure still mentions the internet connection.

## The live bug fixed on the way

The owner could not get a code on the live site ("The code could not be sent."). Cause: the live Supabase project's SMTP port was **585**; Brevo accepts 587, 465 or 2525, and Brevo's log held no Aleksi email at all. Set to 587 in the Supabase dashboard (Authentication, Emails, SMTP Settings) with the owner's OK. The owner then received her code.

Lesson for AGENTS.md, not added because that file is already over its 2,200 word limit on main (2,256 words; `tests/agents-md.test.ts` fails): **After setting up an email sender, send one real code on the live site and see it in the sender's log; a wrong SMTP port failed every sign in silently. (signup-choice, owner)**

## Tests and what they protect

- `e2e/signup-choice.spec.ts` (new, mocked, no database): `[signup-choice 1]` to `[signup-choice 10]`, including axe, 375 x 812 fit, 320 px at 200 percent, the Turnstile token on both buttons, the failure line, and only exact `then=lesson`.
- `src/lib/app-paths.test.ts` (new): `[signup-choice 8]`.
- Updated to the owner's new words or the new button name: `src/screens/protected-copy.test.ts`, `e2e/road-start.ts`, `road-stops`, `front-door`, `account-pages`, `design-reference`, `redesign-pages`, `accounts`.

## Check results

- `npx tsc -b`, `npx eslint`, Vitest (`src/screens`, `src/road`, `src/lib/app-paths.test.ts`): passed.
- Playwright, Chromium and WebKit, `signup-choice`, `road-stops`, `signin-center`, `redesign-pages`: 214 passed, then the 4 `redesign-pages` email screen tests updated to the new words and passed (12 of 12).
- Not run here: `save-progress` and `accounts` need the local Supabase database, which was not running on this computer.
- Pull request check: secret scan passed.
- Live: the deployed bundle contains the new buttons and sentences (checked by reading the script file, no lesson started).

## Not done

- `factory/board.json` and `factory/progress.md` are the manager's files and were not touched.
