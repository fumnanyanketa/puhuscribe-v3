# signup-choice: create an account or continue as a guest

Fast route, owner decision 22 November 2026. Branch `factory/signup-choice`, worktree `.worktrees/signup-choice`.

Flag: **look closely** (sign in).

## Why

On 22 November 2026 the owner found that making an account is hard. A visitor becomes a guest without being asked, and the only way to an email account is the account page's "Create" after a lesson. "Sign in with your email" never makes an account. Her words: "once before the lesson starts, we should encourage people to create an account... there should be an option. It should be very visible. Create an account or continue as guests."

This replaces the earlier choice not to ask for sign up before lessons. Guests must still be able to start at once.

## What the owner chose (22 November 2026, from the options page https://claude.ai/artifact/RzxkiWzTm6DUNu1Yz2E3ML)

| Call | Options shown | Her choice |
|---|---|---|
| Where the choice goes | A. Aleksi's stop screen. B. A screen of its own. C. The road, in place of Start. | A, the stop screen |
| Which button is the green one | "Create an account" or "Continue as guest" | "Create an account" |
| What "Create an account" does | Email, code, then the lesson; or email then the lesson at once, code later | Email, code, then the lesson |
| A sign in link under the buttons | Yes or no | Yes |

## How it works

- Only a visitor with no account on this device sees the choice (the stop screen's existing `visitor` flag). Guests and email accounts see the one "Continue" as before.
- "Continue as guest" does what Continue did: it makes the guest through the Turnstile check, then opens the lesson.
- "Create an account" makes the guest the same way, through the same Turnstile check, then opens the existing "Create your account" screen at `/learn/account/email?then=lesson`. The email is added to that guest with the existing routes. The server is not changed: email accounts still only ever start as a guest that passed the bot check.
- In this "first lesson" mode the email screen's back arrow goes to the road, the long warning about deleting guest progress is replaced by a short line (the new guest has no progress yet), and after the code the Continue button opens the lesson instead of the road.
- If the visitor gives up at the email step, they are a guest and can start from the road as usual.

## Done when

1. A visitor with no account on this device sees two full width buttons on Aleksi's stop screen: the mint "Create an account" with its arrow on top, the white "Continue as guest" under it.
2. "Continue as guest" makes the guest through the same Turnstile step as before and opens the lesson.
3. "Create an account" makes the guest through the same Turnstile step, then opens `/learn/account/email?then=lesson`. If making the guest fails, the same problem line shows as for Continue and nothing else happens.
4. Under the buttons: the line "Already have an account? Sign in", with Sign in linking to the sign in screen, then the existing guest line and Privacy notice.
5. A guest or an email account sees the single "Continue" as before, with no account buttons and no sign in line.
6. On `/learn/account/email?then=lesson`: the back arrow says "Back to the road" and goes to the road; under the field is only the line "We’ll email you a 6 digit code." with no guest progress warning.
7. After the code is accepted in that mode, the screen says "Your account is ready." for a new address, or "You are signed in to your account." when the address already had an account, and Continue opens the lesson.
8. Only the exact value `then=lesson` changes the email screen. Any other value, or none, keeps today's screen, back link and road destination. The destination is fixed in the code; nothing from the address bar is used as a link.
9. At 375 x 812 the stop screen with both buttons fits without scrolling; at 320 px wide with text at 200 percent nothing runs sideways and every button stays reachable.

10. On "Create your account", when the server answers but cannot send the code, the message is "We couldn’t send the code right now. Please try again in a few minutes."; only a real network failure still says to check the internet connection.

## Added the same day (owner, 22 November 2026, after the live bug on "Create your account")

- Less text under the email field (owner's choice "One line + short warning"): "We’ll email you a 6 digit code." for everyone, and only from the account page (a guest who may have progress) "If this email already has an account, your guest progress on this phone is replaced." The sign in screen keeps its line as it was.
- The send error no longer blames the learner's internet when the server failed (statement 10).
- The live cause, fixed in the Supabase dashboard with the owner's OK and not in code: the live project's SMTP port was 585; Brevo accepts 587, 465 or 2525. It was set to 587 on 22 November 2026.

## Threat model (sign in is touched)

- **Worst thing a malicious person could do here.** Make many accounts with bots. Unchanged: "Create an account" goes through the same `/api/guest` Turnstile check as Start, and no new route makes accounts. Learn which emails have accounts: unchanged, the same code routes give the same answer for every address, and the new short line is the same for every address.
- **Data we store and must protect.** The email address, as today, only after the learner confirms the code. Nothing new is stored. The `then` value is never stored or sent to the server.
- **What the system refuses even if asked nicely.** It never sends the learner to an address taken from the page address (no open redirect): `then=lesson` only switches to a fixed path in `src/lib/app-paths.ts`.

## Not in this job

- No change to the road, Aleksi's intro, the account page, or the sign in screen.
- No change to the server or the database.
