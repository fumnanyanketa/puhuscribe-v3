# Evaluation: 14-analytics, after round 2

Evaluated 30 October 2026 on branch `factory/14-analytics`, head `5df704c`. Head `5df704c` differs from `dd81f18` only in `build.md` and two evidence files, so GitHub run 41056806046 on `dd81f18` (all jobs green) tests the code as it is now.

## How it was tested

There is no Docker on this machine, so there is no local database, and no preview link exists yet. I used four kinds of proof:

- **GitHub run 41056806046.** I read its log myself. Every analytics browser test ran and passed in Chromium and WebKit, and the journey test passed in its own project. None of the 31 skipped tests is an analytics test. All 903 pgTAP tests and the 9 parallel tests passed (`eval-ci-run-41056806046-read.txt`). I looked at the report's screenshots. I copied two of them, after checking they show no email address. I left out traces, HAR files and videos.
- **The three statement 9 break runs.** I read the logs and the commit diffs myself. Each run removes one condition, and only that condition's test goes red (same file).
- **Local Vitest and the type check.** The 10 analytics test files gave 141 passed (`eval-vitest-local.txt`). `tsc -b` passed. In the full local run, two job 4 tests timed out on this machine (gitleaks). They are green on GitHub and unrelated to this job.
- **My own browser checks.** I ran the real pages at 375 x 812 in Chromium and WebKit against the local dev server. Only the `/api` answers were stood in for (`eval-browser-checks.txt`, `eval-19-double-send.txt`).
- **My own break checks.** I took a throwaway copy of the code outside the repository, broke six protections one at a time, and confirmed their tests go red (`eval-break-checks.txt`).

I changed no app code.

## Results

| # | Result | Evidence | What I saw |
|---|---|---|---|
| 1 | pass | `eval-break-checks.txt`, `eval-vitest-local.txt` | 28 table cases, including every case the spec names. When I made every `Sec-Fetch-Site` count, or counted every page answer, the matching tests went red. |
| 2 | pass | `eval-vitest-local.txt` | The country is the code, or `XX`, or `T1`. The database call carries only `{"p_country":"FI"}` and the headers `apikey` and `content-type`. |
| 3 | pass | `eval-vitest-local.txt` | `run_worker_first` matches the page routes, checked against `src/App.tsx` in both directions. The built files check runs on every build. `/voice` was correctly added. |
| 4 | pass | `eval-vitest-local.txt` | The page is the same object `ASSETS` returned. A failing or hanging database adds no header and writes no log line. |
| 5 | pass | `eval-ci-run-41056806046-read.txt` | pgTAP checks the exact columns, the key and no access for every API role. |
| 6 | pass | `eval-ci-run-41056806046-read.txt` | pgTAP covers `fi`, `FIN`, `F1`, an empty value and null. Two connections at once give a count of 2. |
| 7 | pass | `eval-browser-checks.txt`, CI | The guest walk and my own runs made no request off localhost. The owner host never counts, and redirecting that host's routing turns this test red. |
| 8 | pass | CI pgTAP | Each number matches the hand worked answers, and empty data gives no division by zero. |
| 9 | pass | `eval-ci-run-41056806046-read.txt`, `break-9-*.txt` | Three break runs, each with only its own test red (89, 90, 88). |
| 10 | pass | CI pgTAP | The cost catalogue test, plus a cost table added later, counted without changing the function. |
| 11 | pass | CI, `eval-vitest-local.txt` | Exactly 10 keys. No seeded id or email appears, and no `@` at all. The banned words check passes. |
| 12 | **fail** | `e2e/analytics-journey.spec.ts`, `worker/providers/speech-feedback.ts` line 270 | The fake speech provider records `cost_usd = 0`, so the cost check "before + 0" passes even if the cost is never counted. See failure 1. |
| 13 | pass | `eval-break-checks.txt`, `eval-13-17-ci-owner-page-local-db-chromium.png` | Routes, the 404s, the redirects and the missing settings case all hold. |
| 14 | pass | `eval-break-checks.txt` | I made the check "always allow" myself, and 7 owner tests went red. The six refusals each change one thing. |
| 15 | pass | `eval-15-owner-not-on-list.png`, CI | An account not on the list sees the refusal and no number. The publishable key and the owner's own token are used. |
| 16 | pass | CI pgTAP | No API role can read or write the list. `my_owner_rows()` returns only the caller's row. A learner's download shows `[]`. The README holds the SQL line. |
| 17 | pass | `eval-17-owner-page-full.png`, `eval-17-owner-page-learners.png` | Every section, text format and goal is as the spec says. The tables are real tables, with no chart, filter or date picker. |
| 18 | pass | `eval-break-checks.txt`, CI | Private headers are on every kind of answer. GET only. Other origins are refused (red when I removed that check). |
| 19 | **fail** | `eval-19-double-send.txt`, `eval-19-feedback-second-tap-while-sending.png` | The links, texts and count are right, but a second tap or Enter while "Sending" posts the same message again. See failure 2. |
| 20 | pass | `eval-20-owner-feedback-plain-text.png` | `<script>` and `<img onerror>` show as typed and run nothing. There is no link. The 40 letter word wraps at 375 and 320 px. |
| 21 | pass | CI pgTAP | Learner A cannot read or add B's messages and cannot set `created_at`. Nobody can change or delete messages. `anon` can do nothing. |
| 22 | pass | `eval-22-feedback-sixth-gentle-line.png`, CI | The 6th message is refused, also from two connections at once. The 429 shows the gentle line, and the body is capped at 8 KB. |
| 23 | pass | CI pgTAP | Feedback is in the download and is deleted with the account. Job 11's tests only gained seed rows; no assertion changed. |
| 24 | pass | `eval-24-error-boundary.png`, `eval-24-error-boundary-webkit-dark.png` | A broken dashboard answer shows "Something went wrong on this screen." and Reload (54 px, problem style), and sends one report. At most 5 reports per page load. |
| 25 | pass | `eval-browser-checks.txt`, `eval-break-checks.txt` | A typed answer, an email, an id and a long number all came out as `[typed]`, `[email]`, `[id]` and `[number]`. When I removed the Worker's cleaning, its test went red. |
| 26 | pass | CI pgTAP | Each field is refused when wrong. Caps at 30 and 300, also when parallel. The 30 day deletion and the daily cron job are in place. |
| 27 | pass | `eval-27-owner-crashes.png`, CI | The owner test error and the front door error both appear in both browsers. A double tap on "Send a test error" sends one report. |
| 28 | pass | `eval-vitest-local.txt` | Only `worker/providers/crash-reports.ts` calls `report_crash`, and it is listed under Supabase. |
| 29 | pass | `eval-29-privacy-notice-not-linked.png`, `eval-29-privacy-notice-feedback.png`, `eval-29-privacy-notice-owner-row.png` | The notice matches the code. See the note on its wording below. |
| 30 | pass | CI, `eval-vitest-local.txt` | POST and JSON only, 403 for another origin, no CORS header. Crash reports carry no cookie on the app host. Logs are watched in the visit, feedback and crash tests. |
| 31 | pass | CI, `eval-browser-checks.txt` | No sideways scroll at 320 px or 200 percent text. Controls are 44 px or more, and everything works by keyboard. Axe found nothing in light or dark. |
| 32 | pass | CI (types diff step), README, docs | Data model, conventions, README setup and the €0 cost line are written. The types file matches the CLI's output. |
| 33 | not provable yet | none | It can only be checked after go live (owner's call 2). This is not a failure. |

## Failures

### 1. Statement 12: the journey's cost check cannot fail (must fix)

The journey test makes one speech check with the fake provider. The fake provider's cost is always 0 (`worker/providers/speech-feedback.ts` line 270, `costUsd: () => 0`). The test then asserts `after.ai_cost_usd.total` ≈ `before.ai_cost_usd.total + cost`, which is `before + 0`. If `owner_dashboard()` ignored the new speaking attempt entirely, this check would still pass. So "each of the seven numbers shows the expected change" is not proven for the cost. The other six numbers, the feedback list and the crash list are checked properly.

Steps to see it:
1. Read `e2e/analytics-journey.spec.ts` lines 121 to 125 and 209.
2. The fake provider gives `cost` = 0.
3. The assertion compares the total with itself.

A fix in the test is enough. After the speech check, set that attempt's `cost_usd` to a known non zero value in the throwaway database, as the test already moves the sessions back in time. Assert the total grows by exactly that value. Then break the cost sum on a scratch branch and show the test go red.

### 2. Statement 19: one message is stored twice when Send is tapped again while sending (must fix)

While a message is being sent, the Send button shows a spinner and its busy state removes the button's click handler. It is a `type="submit"` button, though, and `FeedbackPage`'s submit handler does not check `sending`. So a second tap or a second Enter submits the form again. On a slow phone connection, a learner who taps again gets the same message stored twice. Both copies count toward the 5 a day, and the owner sees the message twice. `EmailFlow` guards against this with `if (busy) return`; the feedback page does not.

Steps to reproduce (Chromium and WebKit, 375 x 812):
1. Open `/feedback?from=finish` with an account.
2. Type a message and tap Send.
3. While the spinner shows, tap Send again (or press Enter twice).
4. Two identical `POST /api/feedback` requests are sent (`eval-19-double-send.txt`).

The fix is small: return early from `send()` while `sending` is true. Add a browser test that taps Send twice against a slow answer and expects one stored message, and show it red without the fix.

## Odd but not failures

- **Statement 14 proof.** The statement asks for a run link in `build.md` for the "always allow" break. The builder gave a local run instead. I repeated the break myself and 7 tests went red (`eval-break-checks.txt`), so the protection is proven.
- **The privacy notice wording differs from the spec's facts table on purpose.** It now says Cloudflare sees the internet address and PuhuScribe's database does not keep it. It also says what is removed from crash reports, where the table said "nothing you typed or said". I checked both sentences against the code and they are accurate. The owner approves the wording at final approval, along with "visit totals kept as long as the service runs" (no deletion is set).
- **Paths that are not page routes skip the Worker.** For example `/about`, or `/foo` on the owner host, gets the single page fallback straight from Cloudflare. Such paths are never counted. On the owner host they carry none of the Worker's private headers and get no token check, so only Access guards them. The security review accepted this, and those answers hold no data.
- **Country code `ZZ` shows as "Unknown Region".** That is the browser's own name for it, not the code. Cloudflare never sends `ZZ`, so this does not matter in practice.
- **Every cost table must have `user_id` and `created_at`.** `owner_dashboard()` assumes both columns on any table with a `cost_usd` column. A future table without them would make the owner page show "could not be loaded". It fails loudly, not silently, and statement 10's catalogue test would catch it.
- **Worker crash messages are not checked for typed text.** They are cleaned of known shapes only (security note 3). Nothing in the Worker puts learner text into an error today.
- **The median shows "0 minutes" in the CI screenshots.** Test sessions end at once. This is not a defect.
- **The seven departures in `build.md` all keep the intent.** T1 is stored. The owner row reaches the download through `my_owner_rows()`. `/voice` is listed. The parallel tests have their own CI step and the local password is not a secret. The journey is its own project and Chromium only, which the statement allows. The local owner host key is trusted on loopback only, and a test covers that. Earlier tests gained only seed rows and exact list entries.

## For the owner

Two pictures to look at:
- `evidence/eval-17-owner-page-full.png`: the whole owner page at phone size, with test numbers, feedback and crashes.
- `evidence/eval-29-privacy-notice-not-linked.png`: the new privacy notice lines on the visit count and crash reports.

Result: fail
