# Job 6: Pull-request browser tests against a throwaway local database

Flag: routine, with a note. It changes how GitHub checks run and how changes reach the test database, so look at the notes below.

## What changes for you

1. Every pull request now runs the browser tests against a throwaway database that is built from that pull request's own changes and thrown away afterwards. A job that adds a table can now pass its browser tests before you approve it.
2. The shared test project still receives database changes only after you approve and merge, as before. Nothing in this job touches it.
3. The preview link on a pull request that changes the database says so in plain words, because new tables do not work on that link until the merge.
4. Pushes to main that change only notes (`factory/` and `recording/`) no longer run the 14 minute checks. They run a 10 second secret scan instead.
5. Cost is 0 euro. A pull request run now bills about 21 minutes of GitHub time instead of 14, which is over the 20 the spec asked to flag. Private repositories get 2000 free minutes a month, so watch it as many jobs run in parallel.

## Checks and review

- GitHub checks on pull request 14 (head `7958daa`): all green.
- Security review: pass, nothing to fix. The one key that showed up in an old log line is the public default key every local Supabase uses. It opens nothing.
- Design and wording review: pass, 5 small should-fix items, saved in `factory/todo.md`.
- Evaluator: pass. It broke 11 protections on purpose and each test went red. Two things can only be proven after the merge and are listed under "After merge".
- Evidence folder: `factory/jobs/6-pr-local-db/evidence/`. Report: `evaluation.md`.

## Your call that is still open

Statement 14 (how the evaluator and you see a job's new database parts) was built as option A, recorded proof only. You chose option B, Docker Desktop on your PC. B needs Docker installed on your computer. Until then A applies, and it is already built. I will guide the Docker install.

## After merge

- Confirm the merge run applies the database changes, then runs the new "after merge" browser check.
- Confirm a later push that changes only `factory/` files starts only "Secret scan of notes".

Result: ready for owner approval.
