# Job 3-data-model: design and learner experience review, round 1

Reviewer: design. Branch `factory/3-data-model`, diff `main...HEAD`. The job changes no screens, so I judged what the data model allows or forces on later screens, against the product rules in `AGENTS.md`. I read both migrations (`20261020090000_content_model.sql`, `20261020090100_learner_model.sql`), `docs/data-model.md`, and the README, `content/v2-starter/README.md` and `docs/v2-imports.md` changes.

## What the model gets right

- One front door, one loop: no mode, preference, language or profile column exists. `loop_step` is the five steps in order. `review_logs.mode` records how an answer was given (typed or spoken), not a choice the learner makes.
- Both registers with audio: the database refuses to approve a line without both texts, the gloss and both audio keys. Tokens exist per register.
- Nothing unmet is reviewed: a card can be created only after a session of an approved dialogue reached `understand` and contains the form.
- Grammar as a card: a form cannot be approved without `form_name_en` and `why_en`.
- Gentle feedback: the rating is the grader's, never the learner's. No table holds a streak, a milestone, a vocabulary list, a mode or a grammar lesson.
- Voice consent is a history with the version of the text shown. No audio, recording or transcript is stored.
- Docs wording: `docs/data-model.md`, the README change and `content/v2-starter/README.md` contain no em-dashes, no hype words and no "not X, but Y" framing. Checked by search.

## Findings

### Must fix

None.

### Should fix

1. **`dialogues` read rule and `dialogue_lines` (content migration, lines 257 to 271).** A dialogue stays readable while one of its lines is un-approved for a fix, so a learner sees the conversation with a line missing and a beginner loses the thread. Fix: either make the dialogues read rule also require that the dialogue has at least one line and no unapproved line, or state in `docs/data-model.md` and the job 5 notes that the pipeline must set the dialogue back to draft before it un-approves any of its lines.
2. **`units.title_fi` (content migration, line 29).** It is Finnish text a learner sees, with no audio and no named register, which breaks "both with audio". Fix: drop the column if no screen needs it (minimum data), or split it into spoken and written titles with audio keys that approval requires.
3. **`tokens.form_id` and line approval (content migration, lines 74 to 86 and 116 to 124).** A line can be approved while a word in it points to a form that is still draft or retired. The learner would see a word that cannot be tapped, or a tap that opens nothing. Fix: refuse to approve a line whose tokens point to a form that is not approved (and refuse to un-approve a form that an approved line still uses), or document the approval order for job 5 and tell job 6 to handle a missing form card.
4. **`forms.why_en` (content migration, lines 90 to 112).** The rule is "one line why", but the column accepts any length and line breaks, so a paragraph could be approved. Fix: add a check that it has no line break and a length cap (for example 140 characters, the owner picks the number).

### Notes

5. **Cards whose form is later hidden.** A card keeps pointing to a form that was retired or set back to draft, and the learner can no longer read that form. Job 7 must skip such cards in the due queue. Worth a line in `docs/data-model.md`.
6. **Card creation can fail mid session.** If a dialogue or line is un-approved while a learner is at `say` or `keep`, the card insert is refused and a screen would show an error. Job 6 must handle this quietly, with a plain message and a way to continue. A learner never gets blamed.
7. **Session resume is thin.** The table stores only the last finished step. A learner who leaves halfway through a step restarts that step, and nothing stops two open sessions for one learner. Job 6 needs a rule for which open session to resume (the newest). A session with no dialogue (review only) must appear inside the one loop, never as a separate "Review" mode button, and the spec does not say which steps apply to it.
8. **A learner can set `step_reached` to any step.** The step only moves forward, but it can jump from empty to `use`. It is their own data and only affects their own cards, so this is a note, but "met" then means "claimed" for a learner who writes to the API directly.
9. **No word level audio.** The word card shows both registers of a form, but audio exists only per line and tokens have no start or end times. A tapped word can play only its whole line. Fine for v3.0 if intended. Job 6 should not promise per word audio.
10. **`dialogue_lines.speaker` has no language.** Spec calls it a role label such as "Barista" (English). If any speaker label is Finnish it is learner visible Finnish with no gloss or audio. State that it is English in `docs/data-model.md`.
11. **Streaks and word counts can be derived.** `review_logs.review_time`, `sessions.started_at` and the card count would let a later screen compute a streak or "words you know" without any new table. The table check does not catch that. `cards.lapses` and `reps` are also readable. The binding "Not in v3.0" rule must be held in the screen specs for jobs 6 and 7: never show lapses, streak or a word count. One sentence in `docs/data-model.md` would help.
12. **Consent text versions are only labels.** `notice_version` is free text and the data model holds no text. To "demonstrate consent" later, job 8 must keep every version's exact wording in the repository, kept for as long as a consent row refers to it.
13. **Wording in `docs/data-model.md`.** "Tokens" means the words of a line in one table and the login token ("their user id in the token", line 11 and 40) in the text. An owner reading it will confuse them. Fix: say "words of a line" in the explanation and "login token" for the other. Also "catalogue test" and "row level security" are explained only in the README; link or add a few words on first use.

Result: pass
