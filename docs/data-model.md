# Data model

The database every feature stores its data in. It was designed in job 3-data-model; the full decision, with the alternatives and why they lost, is in [factory/jobs/3-data-model/spec.md](../factory/jobs/3-data-model/spec.md#decision). The tables are made by the migrations in [supabase/migrations/](../supabase/migrations/) and their rules are proved by the pgTAP tests in [supabase/tests/database/](../supabase/tests/database/).

There are three kinds of table, kept strictly apart:

- **Learning content**: what a learner studies. Written only by migrations: the content pipeline writes one publish migration per reviewed dialogue ([docs/content-pipeline.md](content-pipeline.md)). A learner can read a row only when it is approved and everything above it is approved too.
- **Learner data**: what each learner did. Each learner can reach only their own rows.
- **Reference data**: material for writing content. No learner can read it.

"A learner" means a signed in user: a guest (Supabase anonymous sign in) or an email account. Both reach the database as the `authenticated` role with their user id in the token. The publishable key without sign in (`anon`) and the `service_role` key can read and write none of these tables.

## Learning content

| Table | What it holds | A learner can | First used by |
| --- | --- | --- | --- |
| `units` | One real situation tied to an A1 "can do" statement, with an English title. It has no Finnish title: every piece of Finnish a learner sees is a dialogue line, with both registers and audio. | Read approved units | Job 5 writes, job 6 shows |
| `dialogues` | One short dialogue inside a unit, in order. | Read approved dialogues of approved units | Job 5 writes, job 6 shows |
| `dialogue_lines` | One line of a dialogue: who says it, the spoken Finnish (`text_puhe`), the written Finnish (`text_kirja`), an English gloss, and a storage key for the audio of each register. | Read approved lines of approved dialogues in approved units | Job 5 writes, job 6 shows |
| `tokens` | One word of a line in one register, in order, linked to the form it is (or to no form, for names). | Read the words of lines they can read | Job 5 writes, job 6 shows (tap a word) |
| `forms` | The thing a learner reviews: one analysed word form with its base form, its written and spoken shape, its name ("partitive singular") and a one line "why". | Read approved forms | Job 5 writes, job 6 shows (word card) |

Each of these four has a status: draft, approved or retired. Approved means the native reviewer approved it; `approved_at` and `approval_ref` (a pointer to the reviewer's signed review record) must be filled in. A line also needs both texts, the gloss and both audio keys, and a form also needs its name (`form_name_en`) and its one line "why" (`why_en`). The database refuses an approval with a missing part. It also refuses:

- a line whose words link to a form that is not approved, so every word a learner taps has a card behind it;
- a dialogue with no approved line, or with a draft line;
- a form whose "why" has a line break or is longer than 140 characters (the cap can be changed by the owner).

While a row is approved, nothing about it can change, and the words of an approved line cannot change either. While a dialogue is approved, its lines cannot be added, removed, moved, approved, set back to draft or retired, so a learner never sees a dialogue with a line missing. Content that a card, session, word or line points to cannot be deleted; it is retired instead, which hides it.

Setting approved content back to draft, or retiring it, withdraws the approval: `approved_at` and `approval_ref` are cleared, and the old pair is kept in `private.approval_history`, which the API cannot reach. Approving it again needs a new time and a reference that row has never had, so changed content can never carry an old review. No pipeline database role exists (job 7-content-pipeline): publish migrations run as the migration owner, so no extra permission on that history is needed.

The order the pipeline (job 5) must follow:

1. To publish: approve the forms, then the lines (with their words), then the dialogue, then the unit.
2. To fix a line: set its dialogue back to draft (learners stop seeing the whole dialogue), set the line back to draft, fix it, and have the reviewer approve the line and then the dialogue again, each with a new review reference.
3. A form can be set back to draft or retired while lines still use it. Learners then cannot read that form or create a card for it. Job 6 shows such a word without a card, and job 7 skips cards whose form is hidden.

No content table has a column that names a learner or the reviewer.

How the pipeline publishes (job 7-content-pipeline). Each reviewed dialogue gets one migration, `supabase/migrations/<timestamp>_publish_<dialogue_slug>.sql`, made by `scripts/generate/pipeline.py`. It inserts the approved forms, then each line as a draft with its words, approves the line, then approves the dialogue and, if needed, the unit. Every `approval_ref` is the reviewer's file path plus the item id, such as `content/reviews/<dialogue-slug>/round-1.json#line-3`, so each approval reference is new. The migration does nothing when the dialogue is already published, so it can run twice. Each line's `audio_puhe_key` and `audio_kirja_key` is `<dialogue-slug>/<line>-<register>-<first 12 characters of the file's SHA-256>.mp3`; the app plays it at `/audio/<key>`. Fixing a published line (step 2 above) is not built yet: the pipeline refuses a dialogue that already has lines.

## Learner data

| Table | What it holds | A learner can | First used by |
| --- | --- | --- | --- |
| `sessions` | One sitting of the loop: which dialogue (empty for a review only session), the furthest step reached (hear, understand, say, keep, use), the start and end time. | Start their own session, move its step forward, set its end time, read their own | Job 6 |
| `cards` | Review state for one learner and one form: when it is due and the scheduler's numbers. One card per learner per form. | Create a card only for a form they met (see below), update its review state, read their own | Job 6 creates, job 7 reviews |
| `review_logs` | One row per review: the grader's rating (1 to 4, never the learner's own), typed or spoken, and the scheduler's numbers before the review. Never changed. | Add and read their own | Job 7 |
| `usage_events` | One row per product event: who, which event (today only `first_session_completed`), which session, and when. Nothing about the device, browser or address. At most one `first_session_completed` per learner. Never changed. | Read their own; add one only for their own session that reached at least "understand" and has ended | Job 8-first-session |
| `consents` | Voice consent history: one row per choice (voice processing, or keeping recordings), given or withdrawn, the version of the consent text shown (a short label of at most 32 letters, digits, dots, dashes or underscores, such as `2026-10.1`), and the time. The current choice is the newest row of each kind. Never changed. | Add and read their own | Job 8 |

Rules that apply to all of them:

- **Only your own rows.** Each rule compares the row's `user_id` with the user id in the token. Nobody can read, change or add rows for another learner.
- **Nothing unmet is reviewed.** A learner can create a card for a form only after they reached at least "understand" in a session of an approved dialogue that contains that form.
- **No deletes by learners.** Rows go only when the user is deleted.
- **Guests keep everything.** Every table links to `auth.users(id)`. Supabase keeps the same user id when a guest adds an email (job 11-accounts builds this), so every row stays attached. No rule looks at whether the learner is a guest.
- **Export and deletion.** Deleting a user from `auth.users` deletes all their rows in every learner table (`on delete cascade`). A catalogue test fails if a future table with a `user_id` forgets this or forgets row level security.
- **No audio or transcript.** None of these tables stores audio, a recording or a transcript of the learner. Job 8 adds its own tables for that.

### Ending a session: `public.complete_session(session_id)`

Added in job 8-first-session. When the finish screen opens, the Worker calls it once, as the learner. In one transaction it:

1. refuses (and writes nothing) when the session is not the learner's own, has no dialogue, or has not reached "understand";
2. sets the session's `ended_at`, unless it is already set;
3. adds a card with the default values (equal to `createEmptyCard()`) for every approved form that any word of the dialogue's lines links to, skipping cards the learner already has;
4. adds one `first_session_completed` event, unless the learner already has one.

It runs with the learner's own rights (`security invoker`), so every rule above still applies inside it: it sees only approved content, only the learner's own session, and the card rule decides which cards may be made. Calling it again changes nothing. Only the `authenticated` role may call it.

### The daily review: `review_queue`, `next_review_day` and `record_review`

Added in job 9-daily-review (Keep it). Three functions, no new table or column. Each runs with the learner's own rights (`security invoker`), with an empty search path, and only the `authenticated` role may call it, so every rule above still applies inside them.

**When a card is reviewable.** One rule decides it: the card's form is readable by the learner (approved), its `due` time has passed, and the Helsinki calendar day it was last touched (`last_review`, or `created_at` if it was never reviewed) is before today's Helsinki day. So a word met today first comes back tomorrow, and a word reviewed today does not come back again today, even when the scheduler gives it a due time minutes later. "Today" is worked out in Postgres in the `Europe/Helsinki` time zone, never from the learner's device.

- `public.review_queue(p_limit)` returns the learner's reviewable cards (form id, `reps`, `due`), oldest `due` first, then lowest form id, at most the smaller of `p_limit` and 15.
- `public.next_review_day()` returns one row: today's Helsinki date, and the earliest Helsinki day on which one of the learner's cards becomes reviewable by the same rule (never before today), or no day when the learner has no card with a readable form. The front door words these two dates.
- `public.record_review(...)` saves one review in one transaction: it updates the card to the values the Worker's scheduler worked out and adds one `review_logs` row with the grader's rating and the answer mode. It does so only while the card's `reps` still equals the value the Worker read; otherwise it writes nothing and returns false. The card is found by its form through the cards rules alone, so the rules decide whose card it can be (a pgTAP test proves it, and goes red if the function is made `security definer`). A log row that fails its checks undoes the card update too.

The typed answer itself is never stored anywhere. Review logs are learner data: a dated record of what each learner remembered and missed. They are deleted with the learner (`on delete cascade`) and must be part of the learner's data export (job 11).

**Unused guest accounts (owner's decision of 20 October 2026, for job 9):** a guest account with no activity for 90 days is deleted, together with all its rows. Job 11-accounts built the clean up (see "The daily clean up" below) and states it in the privacy notice. Supabase does not delete anonymous users by itself.

### Accounts and personal data (job 11-accounts)

Three functions a learner may call, each with no argument, so nobody can name another learner. Only the `authenticated` role may call them. Migration: `supabase/migrations/20261022072911_accounts.sql`; tests: `supabase/tests/database/accounts.test.sql`.

| Function | What it does | Runs as |
| --- | --- | --- |
| `public.my_account()` | The caller's own account: id, email, guest or not, when it was made, last sign in, when the email was confirmed. No row when the sign in is no longer live, meaning the token's `session_id` is not in `auth.sessions` (signed out, or the account deleted). The Worker learns who is signed in from this, not from Supabase Auth. | The owner (`security definer`), because learners cannot read `auth.users` |
| `public.export_my_data()` | Every row of the caller's in every user table, each row with every column, as one JSON object under `tables`. The "Download my data" file is built from it. | The learner (`security invoker`), so each table's read rule applies |
| `public.delete_my_account()` | Deletes the caller's own `auth.users` row; the cascades remove every user table row. Refuses, writing nothing, when the token has no user id or its sign in is not live. | The owner (`security definer`), because learners cannot delete from `auth.users` |

**The export check.** A user table is any table, in any schema this project creates, with a `user_id` column or a link to `auth.users`. The pgTAP test finds them in the database catalogue (skipping Supabase's own schemas by name) and fails when `export_my_data()` does not list exactly those tables, or when an exported row misses a column. So a job that adds a user table must add it to the export and to `src/privacy/data-inventory.ts` in the same job.

**The daily clean up.** `private.delete_inactive_guests()` deletes guest accounts with no learning activity for 90 days (owner's decision of 20 October 2026) and email accounts with none for 24 months (owner's decision on job 11), with all their rows. Activity is the latest of the account's creation, its sessions' start and end and its reviews. It skips anyone for whom `private.user_has_stored_files(user_id)` is true; that function answers false today and is replaced by a job that keeps a learner's files outside the database, so the clean up never leaves files behind. Supabase Cron (`pg_cron`) runs it every day at 03:17 UTC (job name `delete-inactive-accounts`). No API role can run it. Supabase does not delete anonymous users by itself.

## Reference data

| Table | What it holds | Who can read or write | First used by |
| --- | --- | --- | --- |
| `source_sentences` | Sentences from earlier material, kept as reference when units are written. Keyed on (`source`, `source_ref`). | Nobody through the API; only migrations write it | Job 5, when writing units |
| `lemma_ipa` | Pronunciation (IPA) for 514 Finnish base forms from v2, with its source and licence ("English Wiktionary via kaikki.org, CC BY-SA 4.0"). | Nobody through the API; only migrations write it | Not decided; showing IPA to learners needs that attribution line |

A sentence from `source_sentences` that is reused in a unit becomes a new dialogue line and is approved by the native reviewer in its dialogue, like every other line (owner's decision of 20 October 2026).

## The `visits` table (removed)

Job 2-smoke's "Hei!" page saved one row per page load in `visits` (a number and a time, nothing about the visitor). Job 8-first-session replaced that page with the front door and dropped the table (`supabase/migrations/20261021182906_drop_visits.sql`).

## Loading v2's data again

The loader lives in [scripts/v2-import/](../scripts/v2-import/). It reads copies of v2's files taken at commit `9c8d0a083d6209e0135efe20f88db99ff9c867e4` (the commit the engines came from, see [docs/v2-imports.md](v2-imports.md)). Each copy is checked against its git blob hash, so a changed copy stops the import. The output is a migration of upserts, so loading twice changes nothing; the database check runs every `*_load_v2_*.sql` migration a second time on purpose.

**Pronunciation data (loaded in job 3).** To rebuild the migration, from the repository root:

```
node scripts/v2-import/build.ts copy ipa --v2-clone C:/Users/fumna/dev/_v2-readonly
node scripts/v2-import/build.ts ipa
```

The first line is needed only if `content/v2-starter/from-v2/` is missing; it copies the file out of a local clone of v2 at the pinned commit. The second writes `supabase/migrations/20261020090300_load_v2_lemma_ipa.sql`. `npm test` fails if that file differs from what the script makes, and the pgTAP tests check the 514 rows and their fingerprint in the database.

**The 104 starter sentences (waiting for the owner's corrections list).** Owner's decision of 20 October 2026: nothing from the 104 loads until the reviewer's marked up corrections are typed into `content/v2-starter/corrections.tsv` and the reviewer has checked the typing. The file is a header line and one tab separated row per change:

| Column | What goes in it |
| --- | --- |
| `sentence` | The sentence number, 1 to 104, as in v2's review sheet |
| `register` | `puhe` (spoken) or `kirja` (written) |
| `before` | The text exactly as it is in v2. The loader stops if it differs by even one character |
| `after` | The corrected text |

A sentence's register can be corrected only once per file. When the checked list is in:

```
node scripts/v2-import/build.ts copy sentences --v2-clone C:/Users/fumna/dev/_v2-readonly
node scripts/v2-import/build.ts sentences --out supabase/migrations/<timestamp>_load_v2_starter_sentences.sql
```

Then that round adds the same tests the IPA data has (copy matches v2, migration matches v2 plus corrections, a pgTAP row count of 104 and fingerprint) and replaces the test that says no migration loads the sentences yet.

Until then the loader is tested only on made-up fixture sentences in [scripts/v2-import/fixtures/](../scripts/v2-import/fixtures/): `node scripts/v2-import/build.ts fixture` rebuilds their load SQL, and the database check loads it twice inside a transaction that is rolled back.

## When database changes reach the test project

Owner's rule from job 3-data-model: database changes reach the shared Supabase test project only after the owner approves a job, which is when it is merged to main. On a pull request, every migration and every pgTAP test runs on a throwaway local database inside the GitHub check, and the job "Apply database changes to the test project" is skipped. It runs on the push to main and then runs the same tests on the test project.

The browser tests follow the same rule (job 6-pr-local-db). On a pull request they run on their own throwaway local Supabase with the pull request's migrations, so a job that adds a table can test it before approval, and parallel jobs never share a database. After the merge, once the apply job has succeeded, they run again against the test project, leaving out tests tagged `@seed`. The preview link still uses the test project: on a pull request that changes `supabase/migrations/`, only the Cloudflare Access lock tests run on it, and screens that need the new database parts work there only after approval.
