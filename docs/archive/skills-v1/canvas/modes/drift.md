# /canvas drift

The consistency patrol. UI drifts apart slowly: a slightly different button
here, off scale spacing there. Users cannot name it, but it is why an app
feels cheap. This mode catches drift while it is still one screen deep.

## When to run

After each feature that touched UI lands, alongside /sync. Also anytime the
user says the app is starting to look inconsistent.

## The work

1. Read design/design-system.md and design/registry.md. These are the law
   and the census.
2. Scan the UI code changed since the last patrol (the recent diff is the
   scope, same rule as /test).
3. For every new or changed component, check it against the law:
   colors from the palette only, spacing on the scale, approved corner
   radius, fonts and sizes from the system, reusable pieces reused rather
   than re-invented.
4. Update registry.md: add genuinely new approved components, note where an
   existing component was duplicated instead of reused.
5. Write the drift report: each violation with the file, what rule it
   breaks, and the fix in one line. Severity: breaks the look badly, minor
   deviation, or judgment call for the user.
6. Route fixes to /develop as small tasks, or as plan rows if they can wait.

## Rules

- This mode never edits code. It is eyes, not hands.
- If a violation reveals that the design system itself is wrong or
  incomplete, that is a design decision: update design-system.md WITH the
  user's approval, then treat old screens as drift against the new law.
