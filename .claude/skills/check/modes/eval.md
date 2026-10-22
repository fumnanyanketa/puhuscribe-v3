# /check eval

Grade a feature that is itself powered by AI. Regular tests cannot do this
because AI features do not give exact answers. Evals score them instead.

## When this mode applies

Only for AI powered features: a chatbot, an AI search, a summarizer, a
classifier, anything where the feature calls a model. Deterministic features
belong to /test, not here.

## The work

1. Build the golden set if none exists: a small fixed collection of example
   inputs with known good answers, stored in docs/evidence/feature-name/
   golden-set.md. Aim for 10 to 25 examples covering the normal cases, the
   edge cases, and a few inputs the feature should refuse.
2. Run every golden set item through the real feature.
3. Score each result: correct, partially correct, wrong, or refused when it
   should not have (and refused correctly, which is a pass).
4. Write the eval report to docs/reviews/feature-name-eval.md: pass rate,
   the failures verbatim, and a short note on the failure pattern.
5. Set the bar with the user: what pass rate ships? Record the number in the
   feature's spec in docs/specs/ so next time is not a debate.

## Trajectory scoring (open decision D4, default off)

Output scoring asks "was the answer right?" Trajectory scoring also asks
"was the PATH sensible?": right tools, reasonable order, no reckless
shortcuts that happened to work this time. It matters because a sloppy
process that lucked into a right answer will produce a wrong one later.

Default: score outputs only. If the user turns trajectory scoring on for a
feature, additionally record the steps the AI took per golden item and flag
paths that skipped verification or used the wrong tool, even when the final
answer was correct.

## Rules

- The golden set is versioned and grows: every real world failure that gets
  fixed becomes a new golden item so it can never silently return.
- Never tune the feature against the golden set until it memorizes it; when
  the set stops finding problems, add harder items.
