# Design and wording review: 6-pr-local-db

Reviewed head `7958daa` (PR 14) against `main...HEAD`. This job changes no learner screens or learner text, so this is a maintainability and wording review of the PR comment, docs, `scripts/ci/*`, workflow step names and tests.

## Checked and fine

- **No placeholders.** No TODO, FIXME or placeholder text in the diff. The seed folder is real and its loader logs "No browser seed files" when empty, as the spec asks.
- **Test labels.** Every new test in `tests/checks-workflow.test.ts`, `scripts/ci/preview-plan.test.ts` and `scripts/ci/supabase-status.test.ts` carries a `[prdb N]` label. The `[prdb N]` names read as plain sentences.
- **Writing rules in the new docs.** No em dashes, no hyphens as punctuation, no hype words, no "not X but Y". The README, conventions, data-model, seeds README and workflow comments are plain.
- **Replaced tests (statement 11).** Exactly three existing tests changed, and each replacement keeps its protection.
  - `[smoke 11] the browser tests wait for the test project to be updated` is the same two assertions on `browser-test-project`. Nothing weakened.
  - `[data 18] on a pull request the browser tests run once the database tests pass, without the apply job` is removed. Its premise (pull request browser tests use the test project) is gone. `[prdb 1]` (no `needs`, starts with the database check) and `[prdb 8]` (`needs` the apply job, push to main only) cover the new shape.
  - `[data 18] the app, the Worker and the browser tests use only tables already on the test project` is removed. Pull request browser tests now run on the pull request's own tables. After merge, the apply job runs before the test project check. The preview runs only the `@preview` tests on a database pull request. No remaining path can hit an unapplied table, so the protection is not needed.
  - The pinned-actions test gained a third file (`secret-scan-notes.yml`), which makes it stronger.
  - The unchanged `[data 18]` apply job tests, `[data 18]` preview condition test and `[smoke 11]` preview test still stand.
- **scripts/ci readability.** `supabase-status.ts` and `preview-plan.ts` are short, each starts with a header comment saying what it does and which spec statement it serves, and errors name variables, never values. The tests use made-up keys and say so.
- **Workflow step names.** Clear and in plain words ("Start a throwaway Supabase and apply every migration", "The app saved visits in the throwaway database", "Does this pull request change the database?").

## Findings

### 1. should-fix: the preview comment's first paragraph is wrong on a database pull request

`scripts/ci/preview-plan.ts`, `previewComment`, second entry of `parts`. The existing paragraph says "The browser tests in this job already ran against it with the evaluator's service token." On a database pull request only the six Access lock tests run on the preview, and the added note then says the browser tests ran on a throwaway database. The owner reads two sentences that both say "the browser tests ran" and cannot tell which ran where.
Fix: when `databaseChanged` is true, replace that sentence with "Only the Cloudflare Access lock tests ran against it, using the evaluator's service token." Keep the spec's pinned note paragraph unchanged. Update the matching unit test.

### 2. should-fix: the pinned note uses jargon and does not say where to click

`scripts/ci/preview-plan.ts`, the database note (text pinned by spec statement 10). "playwright-report download" means nothing to the owner, and the link goes to the run page, where the download sits under "Artifacts" at the bottom.
Fix: this needs the manager to agree the spec wording changes. Suggested: "...their videos and screenshots are under Artifacts, in the download called playwright-report, at the bottom of this run page: <run link>". If the manager keeps the pinned text, record this as a known limit.

### 3. should-fix: the start log filter can hide a real migration error

`.github/workflows/checks.yml`, step "Start a throwaway Supabase and apply every migration". The `grep -viE 'key|secret|jwt|password|publishable|sb_|eyJ'` drops every line containing those words, case-insensitive. A broken migration commonly fails with "duplicate key value", "foreign key constraint" or "password authentication", and that line would vanish from the log, leaving a red step with no cause. The `[prdb 2]` test only proves key rows are dropped.
Fix: drop only what carries a value, for example lines matching `^\s*(Publishable|Secret|Anon|Service|JWT)` table rows plus `sb_` and `eyJ` shaped values. Alternatively keep the broad filter and print "N lines hidden because they may hold a key" at the end so a reader knows to look elsewhere. Add a `[prdb 2]` case for "duplicate key value violates unique constraint" staying visible.

### 4. should-fix: the `[prdb 13]` label is reused for a different statement

`tests/checks-workflow.test.ts`, three tests labelled `[prdb 13]` (path filter, no filter on pull requests, notes secret scan). Spec statement 13 is "Costs stay at 0 euro and minutes are measured". The path filter and the new `secret-scan-notes.yml` are the manager's extra statement, which is not in `spec.md` (the spec's "Out of scope" even lists skipping checks as a separate decision). A reader who looks up `[prdb 13]` in the spec finds the wrong thing.
Fix: add the extra statement to `spec.md` as statement 16 and relabel the three tests `[prdb 16]`, or say in `build.md` and in a comment above those tests which message from the manager added it.

### 5. should-fix: the README "Preview links" paragraphs are out of order

`README.md`, "Preview links". The last paragraph now starts with the push to main and `secret-scan-notes.yml`, then jumps back to "Cloudflare Access guards every preview link" and the keep awake workflow. The Access sentence belongs with the first paragraph (how the preview is posted), and the push-to-main rule is not about preview links at all.
Fix: move the Access and keep-awake sentences up into the first paragraph. Move the push-to-main sentence to "Database changes" or the checks section. `docs/conventions.md` already says it under "On GitHub".

### 6. note: one rule is written three times

The line "a test that runs against the test project never depends on its row counts or on rows another run wrote" and the seed rules are written in `docs/conventions.md`, `supabase/seeds/browser/README.md` and (seeds) the README. The spec asked for two convention lines and the build added three (the `auto_expose_new_tables` line is extra but useful). Three copies will drift. Keep conventions as the one source and have the seeds README say "See docs/conventions.md" for the rule that is not specific to the folder.

### 7. note: the conventions table cell for browser tests is long

`docs/conventions.md`, "Checks and where they run", the Playwright row's third column holds three facts in one cell. It reads, but a short cell plus one line below the table would scan better. Optional.

### 8. note: the "about 14 minutes" comments are now stale

`.github/workflows/checks.yml` header of `on.push.paths-ignore` and `secret-scan-notes.yml` say a skipped push saves "about 14 minutes". `build.md` measures a pull request run at 21 minutes. A push to main runs a different set (no preview, the after-merge browser check instead), so the number is probably still near 14, but nobody measured it. Say "about 14 minutes (measured before job 6)" or remove the number.

### 9. note: spec versus build count of excluded services

`build.md` already records that the spec says "the other nine names" while the CLI accepts thirteen, so ten are excluded. The workflow comment and the `[prdb 1]` test follow the real list. No change needed in code. The manager may want to correct the spec sentence.

## Result

Result: changes needed

All five should-fix items are wording or doc order and one log filter. There is no must-fix. Nothing in the diff deletes or weakens a protection.
