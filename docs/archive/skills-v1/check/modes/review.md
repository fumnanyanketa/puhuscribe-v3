# /check review

A senior code review by fresh eyes: a DIFFERENT AI model than the one that
wrote the code. A model reviewing its own work shares its own blind spots,
like a person proofreading their own essay.

## The different model rule (non negotiable)

The reviewer must not be the model that built the feature. Acceptable ways
to satisfy it, in order of freshness:

1. A different AI family entirely (for example the free Gemini CLI reviewing
   Claude written code).
2. A different Claude model than the builder, in a fresh session.
3. If neither is possible right now, say so plainly and let the user decide
   whether to accept a same model review as a weaker substitute.

## The work

1. Collect the diff (the exact line by line changes) for this feature, plus
   AGENTS.md and the feature's decision record. The reviewer judges against
   THIS project's standards, not generic taste.
2. Run the universal review prompt:

   You are a senior code reviewer. You did NOT write this code.
   Read AGENTS.md (pasted below). These are this project's standards.
   Read the decision record for this feature (pasted below).
   Review the following changes against: correctness, security,
   the project's own standards, and general best practices.
   Report ONLY problems, ranked Critical / High / Medium / Low,
   each with the file, the line, and why it matters.
   Do not rewrite the code. Do not praise. If something is fine, stay silent.

3. Save the findings to docs/reviews/feature-name-review.md with the date
   and which model reviewed.
4. Route: Critical and High findings go back to /develop before anything
   else happens. Medium and Low become plan rows or notes, at the user's
   choice.

## Free tooling notes

- CodeRabbit has a permanent free plan (pull request summaries, IDE and CLI
  reviews, roughly 4 pull request reviews per hour; full features free on
  public repos). Good as an automatic first pass on GitHub.
- The deterministic layer stays on underneath: linter, type checker, secret
  scanner. Zero tokens, zero doubt. AI judgment sits on top, never instead.

## Rules

- This mode never edits code and never softens findings to be polite.
- Heavy weight features must not skip review, ever.
