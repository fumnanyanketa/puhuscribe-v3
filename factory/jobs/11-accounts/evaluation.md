# Evaluation: 11-accounts (Accounts and personal data)

Evaluator run, 26 October 2026. I tested the app code at `b04cad0`. The worktree has since moved to `bfbdd5c`, and those commits change only tests and the checks workflow. The built app ran from a private copy against its own local Supabase (`puhu11eval`, ports 58321, 58322 and 58324 for Mailpit), served over HTTPS by `vite preview` on port 4211, and I drove it with Playwright Chromium at 375 x 812. Two devices means two separate browser contexts. All addresses were on example.com. My own probe script is outside the repository. Its notes are `evidence/eval-run-notes-1.txt`, `-3.txt` and `-4.txt`, with the codes blanked.

Other checks I ran: `supabase test db` (`evidence/pgtap-output.txt`), Vitest in the worktree (`evidence/vitest-output.txt`: 699 passed, 2 skipped), and the builder's browser tests on my build (`evidence/builder-browser-tests-both-browsers.txt`: 63 passed on Chromium). WebKit could not start on this machine because no WebKit build is installed.

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `1-front-door.png` | The front door shows the Privacy notice link, the Your account link and "I already have an account". Loading it left `auth.users` at 14. |
| 2 | pass | `2-account-none.png`, `2-account-guest.png`, `2-account-email.png` | Each of the three states shows the exact wording from the spec. There are no counts. A guest gets the one line about not being able to sign back in and no Sign out. |
| 3 | pass | `eval-run-notes-1.txt`, `24-functions-and-grants.txt` | `/api/me` answered `{"kind":"none"}`, `{"kind":"guest"}` and `{"kind":"email","email":...}`, with no id and no token. When anon called `rpc/my_account` it got 401 `permission denied`. The grant list shows `authenticated` only. The function is security definer with an empty search_path. |
| 4 | pass | `4-add-email-screen.png`, `4-invalid-email.png` | Both texts appear and the field is `type=email` with `autocomplete=email`. Empty input, spaces, `notanemail`, `a@b` and a 261 character address each got the gentle line, with 0 requests sent. An email account posting to the route got 409. A double tap on Send code sent 1 email. |
| 5 | pass | `5-code-screen.png`, `5-wrong-code.png`, `5-expired-code.png`, `5-resend.png` | The code field has `inputmode=numeric` and `autocomplete=one-time-code`. Resend is disabled with the one minute text, is enabled after 61 s and sends a new code. A wrong code, an empty code and a code backdated 2 hours each gave the gentle line and changed nothing. |
| 6 | pass | `6-email-added.png`, `eval-run-notes-1.txt` | After the code the user id was the same, `is_anonymous=false`, the email matched, and sessions, cards and usage_events were byte identical (1, 12 and 1 rows). `auth.users` count did not change. The page showed the success text. |
| 7 | pass | `eval-run-notes-1.txt` | After Send code and after a wrong code the database had `is_anonymous=true` and an empty email. `config.toml` has `enable_confirmations = true`. |
| 8 | pass | `8-taken-email-code-screen.png`, `8-taken-email-signed-in.png` | A guest entered B's email and got the same screens. After the code the device was B, B's rows were unchanged, and the guest's user row and all its table rows were gone. The page showed the correct text. |
| 9 | pass | `eval-run-notes-1.txt` | Add email with a new address and with a taken address (uppercased): both `200 {"sent":true}`. Sign in with an unknown address and a known one: both `200 {"sent":true}`. The screen text was identical in both pairs. Worker unit tests pass. |
| 10 | pass | `10-sign-in-code-screen.png`, `10-signed-in.png` | The heading and both lines are correct. The cookie is `HttpOnly`, `Secure` and `SameSite=Lax`. |
| 11 | pass | `11-unknown-sign-in.png` | An unknown address showed the statement 10 text. Mailpit received 0 emails and `auth.users` stayed at 19. |
| 12 | pass | `12-device1-front.png`, `12-device2-front.png`, `18-export-second-device.json` | Both devices show the same front door. The second device's file has B's 12 cards, 1 session and 1 event and no other user id. The builder's two device test, where progress on B shows on A, passed on Chromium. |
| 13 | pass | `13-guest-warning.png`, `13-after-sign-in.png` | The warning text appears with Sign in anyway and Go back. Go back kept the guest. After signing in, the guest and all its rows were gone and the device was the email account. |
| 14 | pass | `14-signed-out.png` | Sign out showed "You are signed out on this device." with "I already have an account". The other device's `/api/me` still answered as the email account. |
| 15 | pass | `eval-run-notes-1.txt` | Both the email change email and the sign in email have the subject "Your PuhuScribe code", a 6 digit code, the two lines, and no `http` in the text or the HTML. |
| 16 | **fail** | `16-privacy.png` | The page loads with no `/api` call and has every section, but "Who is responsible" says the name and contact address "are not filled in yet" (`src/privacy/notice-settings.ts`: `RESPONSIBLE = null`). The spec requires owner's call 2 answered before the build finishes, with no placeholders. |
| 17 | pass | `18-export-email-account.json`, `vitest-output.txt` | The file's tables are cards, consents, sessions, review_logs and usage_events, the same as the inventory and the database catalogue. The processor and file write repository tests pass. |
| 18 | pass | `18-download.png`, `18-export-email-account.json` | The file is `puhuscribe-data-2026-10-26.json` with `application/json` and `no-store`. It holds about, exported_at, account (the 6 fields), tables and `files: {}`. It contains only the caller's user id and no token. "Your file is ready." was shown. |
| 19 | pass | `pgtap-output.txt` | `accounts.test.sql` passes. Anon calling `export_my_data` got 401. It is security invoker. The red scratch run is recorded in build.md as a local run. |
| 20 | pass | `20-delete-confirm.png`, `20-deleted.png`, `20-guest-deleted.png`, `20-rows-after-delete.txt` | The confirmation text is exact. Keep my account deleted nothing. A double tap on Delete, for both an email account and a guest, left the cookies cleared and the front door message shown. The read only catalogue query found 0 rows in every user table and in `auth.users`, `auth.sessions` and `auth.identities`. |
| 21 | pass | `pgtap-output.txt`, `24-functions-and-grants.txt` | The pgTAP tests pass. Anon calling `delete_my_account` got 401. It is security definer with `search_path=""`. |
| 22 | pass | `22-other-device-session-open.png`, `22-other-device-after-press.png`, `22-other-device-reload.png` | The other device was in Hear it when the account was deleted. Its next press showed "You are signed out on this device. Sign in with your email to continue.", and so did a reload. 0 rows were left and the auth cookies were cleared. |
| 23 | pass | `vitest-output.txt`, `pgtap-output.txt` | The unit tests with a fake store pass (order, stop on failure, export). So do the repository test for file writes and the pgTAP test that replaces `user_has_stored_files`. Only the stand in is tested, which the spec allows. |
| 24 | pass | `24-cleanup-rolled-back-check.txt`, `24-functions-and-grants.txt` | In a rolled back check, the guest inactive 91 days and the guest whose last session ended 95 days ago were deleted. The 89 day guest, the guest with a session 10 days ago and the 400 day email account stayed. The cron job runs `17 3 * * *`. No API role can execute it, and PostgREST does not expose the private schema. |
| 25 | pass | `24-cleanup-rolled-back-check.txt` | Owner's call 3 was B. The 800 day email account was deleted, and the notice states the 24 month rule. |
| 26 | pass | `eval-run-notes-1.txt` | Delete from a foreign `Origin` got 403 with no `Access-Control-Allow-Origin`. A form post got 415. The builder's no token and console tests pass. |
| 27 | pass | `builder-browser-tests-both-browsers.txt` | The fit, keyboard and axe tests in light and dark pass on Chromium. WebKit was not run here, and build.md cites a GitHub run where it passed. |
| 28 | pass | `.github/workflows/checks.yml` | The local job's `-x` list no longer has the mail catcher, and the after merge and preview jobs use `--grep-invert "@seed\|@email"`. |
| 29 | pass | `docs/data-model.md`, `docs/conventions.md`, README | The three functions, the clean up and the export check are documented. The `[accounts N]` row and the new table rule are there. Running costs is €0 with the owner setup steps. The types include the new functions. |

## Failures

**16. The privacy notice ships with no controller or contact.**
1. Open `/privacy` with no account.
2. Under "Who is responsible" the page reads "The name and contact address of the person responsible are not filled in yet. PuhuScribe is not open to learners until they are."

The spec says the notice ships only once owner's call 2 is answered, and the house rules forbid placeholders. The builder flags this in build.md as waiting for the owner. Once the owner gives the name and address, the fix is one setting in `src/privacy/notice-settings.ts`.

## Odd but not failures

- The worktree has a stray symlink, `node_modules/node_modules`, pointing to `.worktrees/10-speaking-feedback/node_modules`. It was created at 16:10 today, probably by another agent working in a shared scratch folder. With it in place, Playwright loaded job 10's copy of itself and refused to run. I removed it only from my private copy. The manager should delete it from the worktree.
- A guest has no link to sign in. They reach `/sign-in` only by typing the address, because the spec shows "I already have an account" only when the device has no account. That matches the spec, but it means statement 13's warning is hard for a guest to reach.
- After a sign in that switches accounts, the success page keeps the heading "Add your email" above "You are signed in to your account...".
- Reloading on the code step returns to the email step. The code that was sent stays valid.
- The notice lists voice consent choices under Article 6(1)(b). The facts table gives consent (6(1)(a)) only for voice data from job 10, so this may be fine, but the owner may want to check it.
- In pgTAP, `content_publish.test.sql` tests 11 and 12 fail when the browser seeds are loaded first. That is ordering in my environment: CI runs pgTAP before seeding. `accounts.test.sql` passes.
- Only Chromium ran locally. WebKit relies on the builder's GitHub run.

Result: fail
