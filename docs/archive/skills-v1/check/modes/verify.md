# /check verify

Prove the feature works by driving the real app like a real user, one
acceptance criterion at a time, and record evidence that survives.

## The work

1. Start the app the way a user would meet it (the real dev server, the
   device simulator, the browser). Not a code read. Not a unit test run.
2. Take the decision record's numbered acceptance criteria as a checklist.
3. For each criterion, perform the user journey that exercises it, then
   record proof: a screenshot, a short recording, or a log excerpt.
4. Save proof into docs/evidence/ named so it traces back:
   feature-name/AC-3-wrong-password-error.png (the number is the criterion).
5. Also probe the ugly cases around the feature: empty input, very long
   input, no network if relevant. Note surprises even when criteria pass.
6. Write a one page verify report in docs/evidence/feature-name/report.md:
   each criterion, pass or fail, link to its proof.
7. HEAVY weight features: the report must contain a human sign off line.
   Ask the user to write "approved" plus their initials into the report
   after reading it. Do not proceed to done without it. No AI can take
   responsibility for money or personal data. That line is the point.

## Rules

- A criterion without proof is not passed. "It should work" is not evidence.
- Fail honestly. A failed criterion routes back to /develop (build gap) or
  /debug (something broke), with the evidence attached.
- Never edit code to make verification pass. This mode only observes.

## Why evidence instead of just checking

In a month, when something is weird, the question will be "did this EVER
actually work?" The evidence folder answers that in ten seconds.
