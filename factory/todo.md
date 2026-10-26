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
