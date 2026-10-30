# Factory to-do list

Should-fix items and notes from reviews and evaluations, for the owner to schedule. Faster mode sends these here instead of into a new round.

- (5-design-system) VoiceOver check on a real iPhone.
- (5-design-system) The banned-look test does not catch small caps (font-variant-caps).
- (5-design-system) Production build must force VITE_DESIGN_REFERENCE off at liftoff.
- (5-design-system) Record timer format, in job 8.
- (3-data-model) Re-approval tests for units and forms; enforce a new approval time; the pipeline role's exact permissions on private.approval_history (job 5 content pipeline).
- (2-smoke) Change the test database password (a reviewer log holds it).
- (1-stack) Separate Cloudflare account for previews before liftoff; a daily check that preview links still ask for a login.
- (all) Test-database saves hang now and then after idle; owner chose to check the Supabase logs first.

- Anthropic identity federation (GitHub Actions) instead of a stored API key: consider before real learners (7-content-pipeline, owner setup 21 Oct 2026).

## From 6-pr-local-db design review (should-fix, 21 Oct 2026)
- The preview comment on a database pull request says the browser tests "already ran against it", but only the six Access lock tests did. Reword (6-pr-local-db, design review).
- The comment's "playwright-report download" does not say where to find it (Artifacts at the bottom of the run page). The wording is pinned by the spec, so the owner approves a change.
- The local Supabase start log filter in `checks.yml` hides any line containing "key", so a real error such as "duplicate key value" can vanish from the log. Narrow the filter or print a count of hidden lines, with a test case.
- The path filter and notes scan tests are labelled `[prdb 13]`, which collides with spec statement 13 (costs). Add the manager's extra statement to the spec as statement 16 and relabel.
- README "Preview links": move the Access and keep-awake sentences above the push-to-main paragraph.

## From 7-content-pipeline reviews (should-fix, 21 Oct 2026)
- Publishing does not re-run the reviewer file checks of statement 14 (empty reviewer code, wrong slug or round). `forms.analysis` is published without a check against the chosen Voikko reading.
- Python packages that `anthropic` pulls in are not pinned with hashes; the step that holds both keys installs them fresh. Add a hashed lock file and `--require-hashes`.
- Restrict the pipeline keys to a GitHub environment that only main can use, if the plan allows. Set spend caps on both keys.
- Compare each file in `content/reviews/` with what the reviewer actually sent before the manager commits it. Refuse mp3 files carrying the fake voice's tag as a second guard against fake content.
- Review page: tap targets of 40 px and 24 px, pause and stop for clips, a progress count with links from the error list, dark mode, a redundant "Unit ... Can do" line, "Why" label jargon, wording of owner messages (no internal ids), "Fix" with unchanged text accepted, Firefox untested, focus ring colour drifts from the token. Later rounds ask for approval of "the dialogue as a whole" while showing only changed lines.
- Golden set: add a few harder faithful pairs before the real judge run; show the whole set to the native reviewer once.
- (7-content-pipeline evaluator) Fake content is caught only by its labels: a draft relabelled as real still carries the `puhuscribe-fake-voice` marker in its audio. Check for the marker in publish and in the audio check.
- (7-content-pipeline evaluator) No route runs `judge-golden` or `publish` (neither is a workflow task). No committed test shows `check-committed` turning red. Two messages mislead: round "1" as a string is refused with "the file is for round 1, the page was round 1", and `check-committed` prints "FAILS every check" when one check failed. A 40 MB reviewer file is accepted (no size limit). The README still says the Azure key and resource are not created.
- (7-content-pipeline evaluator) The golden set alternates faithful and changed pairs in a fixed order, which the judge could pick up. Old workflow "Voikko readings (temporary)" is still listed in GitHub Actions.

## From 8-first-session reviews (21 Oct 2026)
- LAUNCH DECISION: Supabase counts every guest under Cloudflare's address, so the hourly anonymous sign-in limit and the token renewal limit (150 per 5 minutes, `supabase/config.toml`) are shared by all learners and may be shared with other Cloudflare customers' Workers. Choose before any outside learner: Turnstile, a secret key with address forwarding, or a Worker rate limit. Test once on the test project. (8-first-session, security review)
- Rename the sign-in cookie to `__Host-puhuscribe-auth` before the app gets a custom domain (`worker/learner-auth.ts`, `isAuthCookie`, `e2e/db.ts`, tests). (8-first-session, security review)
- The `first_session_completed` event is claimed by the learner, not proven (a learner can call Supabase with their own token). Job 14 analytics must treat it as claimed. (8-first-session, security review)
- A lesson withdrawn after a deploy keeps its static `/audio/<key>` file online until the next build. Job 7's copy step must copy only approved lines, and a test should prove it. (8-first-session, security review)
- `docs/data-model.md` line 71 says job 9 builds the 90 day guest clean up, but the spec says job 11. Nothing deletes unused guests yet. (8-first-session, security review)
- Do not let anyone outside the team use the app until job 11 adds the privacy notice, export and delete. (8-first-session, security review)
- (8-first-session design and evaluator) A lost token renewal answer on a bad connection can sign a guest out for good after Supabase's 10 second reuse window; guests cannot get their progress back until job 11. Token renewals share a per address limit like guest sign ins (not verified).
- (8-first-session) "Today's session" has no daily limit: after Done the front door offers Start for the next dialogue at once. The blue words hint shows again on Understand it. The front door heading stays "Today's session" after every dialogue is finished. A signed out visitor on an empty content database is asked to create an account before being told nothing is ready. The WebKit keyboard helper falls back to `focus()`, so only Chromium proves the flow by Tab alone. A draft line inside an approved dialogue is not tested in the browser. "Blue words" names a colour, but changed words are also bold.
- The owner raises the test project's anonymous sign in limit only to what testing needs, not to the local 10,000, and only while previews stay behind Cloudflare Access. (8-first-session, security review)

## From 13-review-site reviews (22 Oct 2026)
- (design) Owner steps in `build.md` read as manager steps; the manager writes the owner guide in chat. The 404 answer gives no way back to the start page. Round links read only "Round 1"; add the dialogue name to each link's accessible name. "Dialogue: slug" is developer text. Nothing says everything is reviewed once no round is waiting. Rounds are listed oldest first. The review page has no link back to the index (job 7's page, byte for byte).
- (security) Anyone with write access to the repository can edit `review-site.yml` on a branch and reach `CLOUDFLARE_REVIEW_API_TOKEN` in a pull request run; GitHub environment secrets and branch protection need GitHub Pro. Keep the token as narrow as possible. Add a GitHub environment limited to main if the repository ever moves to a paid plan.
- (security) Cloudflare keeps the allowed emails in the Access policy and its sign-in records and sends the PIN email; where and for how long is unconfirmed (may be outside the EU), and removing a reviewer does not delete those records. Say so in `docs/content-pipeline.md` and tell the reviewer.
- (evaluator) A failed build leaves an older `dist-review/` in place. The push trigger does not cover package.json, so a dependency update alone does not redeploy. Statement 17 skips when `REVIEW_WORKERS_SUBDOMAIN` is not set: set it before the first deploy and check the test shows passed, not skipped.

## From 9-daily-review reviews (26 Oct 2026)
- (design) "Spoken" or "Written" shows twice on the review prompt, once as the band label and again beside the play control (`src/screens/ReviewItemView.tsx`). Drop one.
- (security, note) `record_review` finds the card by form id only and is safe while it stays security invoker; an extra `user_id = auth.uid()` guard on the update would make it safe either way.

## From 11-accounts reviews (26 Oct 2026)
- (design) Privacy notice cards in `PrivacyPage.tsx` sit in a `ul` that keeps bullet markers and left padding; each card shows a stray dot and is pushed in.
- (design) The contact link in `PrivacyPage.tsx` cannot wrap a long address and may scroll sideways at 320 px; `.inlineLink` already has `overflow-wrap: anywhere` but is unused.
- (design, notes) The account page load failure has no retry button. The sign in code screen has no separate "enter the code" sentence.
- (security, note) `export_my_data()` does not check that the sign in is still live, unlike the other two functions; a signed out token that has not expired can still read its own rows directly, which the read rules already allow.
- (security, note) Each code check calls Supabase's code check twice (`worker/account.ts`); all learners share one limit from the Worker's address. Already a launch item in the 8-first-session list.
- (security, for the owner) The clean up also deletes email accounts after 24 months without activity (owner's call 3, option B).

## From 12-units-1-3 reviews (26 Oct 2026)
- (security, note) `worker/patterns.ts` `tokens()` has no approved-status filter of its own and relies on the database rules.
- (security, note) `supabase/seeds/browser/020_test_fixture_units_2_3.sql` inserts content marked approved; it must never be applied to a real project.
- (security, not checked) The fake voice marker guard from the job 7 list was not found in code; the publish step was not exercised because the sixth dialogue is not drafted yet.
- (9-daily-review evaluator) The answer route grades any owned card, even one already reviewed today; only the screen enforces once a day plus one retry. "Check the spelling below" sits under the word it points to. Some tappable words are narrower than 44 px.

## From 10-speaking-feedback build (26 Oct 2026)
- `.env.example` still needs a `SPEECH_FEEDBACK_PROVIDER` line (exact text in `factory/jobs/10-speaking-feedback/build.md`). The builder would not open a file matching `.env*`; the owner adds the line.
- (10-speaking-feedback design) The "Line N of 3" counter disappears once feedback shows, so a beginner can lose their place (`SayIt.tsx`). Focus is not moved when Say it switches between the consent screen and the line view (`SayIt.tsx`).
- (10-speaking-feedback security, should-fix, costs money) The 40 checks per 10 minutes limit on the say route can be beaten by parallel requests: the count is taken before the Azure call and the attempt row written only after it answers, and failed calls never count (`worker/speech.ts` lines 322 to 341). Take the slot before calling Azure, or count failed calls too.
- (10-speaking-feedback security, notes) A learner can add consent rows directly with any text version label (job 8's grant); only their own rows. "Newest consent" is ordered by time only, so two rows of one kind in one transaction would tie. Nothing exports the two new tables yet; job 11's export must include transcripts and recordings.
- (10-speaking-feedback evaluator) A 5 MB body gets a 500 instead of a 413 locally; job 8's `/api/guest` does the same, so it looks like the local test server. Check on a preview link. With the fake speech service the consent screen names no region, only "in the EU".
- (manager, 26 Oct) `e2e/design-sample.spec.ts` [design 12] is timing sensitive in WebKit: the word lit at the moment of Pause drifted by one ("sä" instead of "Mä" or "oon") on a branch with no app change (run 40361746553). Make the check tolerant of one word of drift or pause at a fixed audio time.
- (manager, 27 Oct) After the owner adds the repository secrets: re-run the failed "Apply database changes to the test project" job on main so job 9's migration reaches the test project, then check the preview link check on each open pull request.
- (12-units-1-3 builder, 27 Oct) One Vitest run showed a single failure that did not repeat on two reruns and was not investigated; watch for it on later runs.
- (10-speaking-feedback round 4) Two new English review texts ("Close. Listen to the word below." and "We could not hear that. Type the missing word instead.") were written by the builder; the owner approves wording at final approval.
- (10-speaking-feedback round 4 security) No learner export path for `speech_checks` or `speaking_attempts` yet; job 11's export and data inventory must cover them (the catalogue test catches it once job 11 merges main). `reserve_speech_check` accepts any `max_checks` from a direct caller; the Worker passes fixed constants and the one day clean up bounds it.
- (12-units-1-3 combined review, 29 Oct) Screen readers hear "Spoken" and "Written" repeated inside every form in the Patterns panel; give each form a group name.
- (12-units-1-3 evaluator, 29 Oct) Brief `ordering-coffee-paying.json` says tea and a bun, but the dialogue has coffee only. Its extra word list has 14 words and only "neljä" is used. The statement 16 test checks the panel at the start of day 4, not after the final review only day. Statement 7 is proven in Chromium and WebKit only.
- (manager, 29 Oct) The four Cloudflare preview secrets (CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID, CF_ACCESS_CLIENT_ID, CF_ACCESS_CLIENT_SECRET) are not on the public repo, so every "Preview link" check is red and statement 8 of job 12 is not checkable. The script `copy-cloudflare-to-github.ps1` is in the manager's scratchpad.
- (manager, 29 Oct) Rotate the Anthropic and Azure keys: both showed in the owner's terminal and the manager read them. Use `Read-Host -AsSecureString` for any key prompt from now on.

## From the review site move (30 October 2026)
- Done 30 October 2026: the old destination puhuscribe.exentrik.co was removed from the Cloudflare Access app, so the learner app can take that address at go live. (13-review-site, manager)
- Add the Finnish reviewer's email to the Access Allow policy "Owner and reviewer" when the owner gives it. (13-review-site, manager)
- The Access service token and the review deploy API token expire on 30 October 2027. (13-review-site, manager)

## From job 14-analytics review (30 October 2026)
- (14-analytics design review) The crash screen has only Reload, with no "Back to the start", and focus is lost when it appears. Add the link and move focus to the status line.
- (14-analytics design review) An account that is not the owner sees "This account cannot open the owner page." with no Sign out, so the person cannot try another email. Add a Sign out button.
- (14-analytics design review) After feedback is sent, focus is lost and the "Thank you" line may not be announced by screen readers. Focus the status line.
- (14-analytics design review) Owner page sentences: the day 7 return explanation is hard to read, the cost goal does not say "per learner", and empty states read "0 of 0 learners" and "none per active learner". Also "1 minutes" when the median is 1.
- (14-analytics design review) The no account feedback page links "Go to the front door"; the rest of the app says "Back to the start".
- (14-analytics design review notes) Some list keys could collide; scrolling table boxes are not keyboard focusable; a pasted message over 1,000 characters is cut silently; the owner host sign in screen uses learner wording.
- (14-analytics security note) Anyone with the Supabase address and publishable key could call `count_visit` directly and inflate visits for any country. Accepted by the spec; capped at 677 rows a day, nothing personal.
- (14-analytics security note) Worker crash messages remove emails, ids and tokens but nothing checks for learner typed text. No Worker code puts learner text into an error today; add a test if that ever changes.
- (14-analytics security note) The owner could use a separate account for the owner page, so the owner page token never sits in the app host cookie.
- (14-analytics evaluator) Paths that are not app pages are served by Cloudflare without the Worker, so they are never counted and on the owner host are guarded only by Access. Country code `ZZ` shows as "Unknown Region" on the owner page. `owner_dashboard()` assumes every future AI cost table has `user_id` and `created_at`. The error boundary screen has no CI test; the evaluator checked it by hand.
- (14-analytics design re-check) "any text typed into a box on the screen" in the privacy notice could say "a field"; the owner may also want a time limit on visit totals (for example 25 months), which is a small migration.
- (14-analytics builder, round 3) The stop hook reports type and format errors in the old worktree .worktrees/10-speaking-feedback (worker/speech-db.ts, many staged changes from before the move to the public repo). Decide whether to rebuild job 10 there or remove that worktree.
