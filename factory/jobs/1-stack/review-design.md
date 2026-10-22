# Design review, job 1-stack, round 1

Scope judged: the design system is not locked (job 4), so I checked only the HTML basics, accessibility basics, wording, product rules, banned styles, and README and docs wording against AGENTS.md. I did not judge visual design.

## What I checked

- `index.html`: `lang="en"` set, `<title>PuhuScribe</title>`, viewport meta `width=device-width, initial-scale=1.0` (no zoom lock), UTF-8, empty favicon so there is no 404. Fine.
- `src/App.tsx`: one `<main>`, one `<h1>PuhuScribe</h1>`, and a `<p role="status">` that screen readers announce when it changes. Heading structure is correct. No colour, font, gradient, badge, icon or emoji anywhere, so no banned style and no drift. No mode picker, word list, streak, or shaming wording.
- No CSS files exist, so there are no Inter, Space Grotesk or Bricolage Grotesque fonts, and no tokens that clash with the owner's choice to import nothing visual.
- README and `docs/v2-imports.md`: no em dashes, no hype words, no "not X, but Y" framing, plain wording that explains consequences. The only mild "not X" phrase is "its pattern is carried over, not its code" in `docs/v2-imports.md`, which is a factual statement of what was copied and is fine.

## Findings

1. Note. `src/App.tsx` line 11 to 13. The three status messages mix styles: "Checking the server." (a sentence) against "Server: ok" and "Server: not reachable" (labels). It is a developer status line that job 4 or the smoke test job will replace. Optional fix when that screen is built: use one style for all three.
2. Note. `src/App.tsx` line 13. "Server: not reachable" gives a learner no next step. Acceptable for a foundation page with no learner flow. The smoke test job should give a plain "try again" message when the first real screen exists.
3. Note. `scripts/generate/README.md` has em dashes, bold asides and a "not passed through" style of wording. It is a byte for byte copy of v2 that the spec requires and `tests/v2-imports.test.ts` guards. It is a developer document, not owner or learner text, so I would leave it unchanged and not edit it to satisfy the writing rules.
4. Note. No tap target, focus state or contrast check applies yet: the page has no interactive elements and uses the browser's default colours. Job 4 must meet the 44 px target and focus rules when it adds buttons.

## Must fix

None.

Result: pass
