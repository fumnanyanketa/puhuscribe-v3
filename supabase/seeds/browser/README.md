# Browser test seed files

Rows that browser tests need, loaded only into the throwaway local Supabase of the pull request check "Browser tests (Playwright, local Supabase)" (`.github/workflows/checks.yml`, job `browser`).

- Every `*.sql` file here is loaded in name order after the migrations and before the tests. The first error stops the check.
- Name files with a number first so the order is clear, for example `010_published_dialogue.sql`.
- These rows are made up for tests. They never reach a hosted database: the database check, the apply job and the after-merge check do not load them, and `supabase/config.toml` seed paths do not include this folder.
- A Playwright test that needs these rows carries the tag `@seed`. Tests with that tag do not run against the test project after merge or on preview links.
- A test that runs against the test project never depends on its row counts or on rows another run wrote.

Spec: `factory/jobs/6-pr-local-db/spec.md`, "Done when" 7.
