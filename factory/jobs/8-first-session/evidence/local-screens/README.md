# Local screenshots, round 1 (21 October 2026)

Chromium at 375 x 812, light and dark, against the built app on this machine
(`vite preview` over HTTPS). This machine has no Docker, so no local Supabase:
the session answers (`/api/sessions/today`, the step and complete routes) were
made up by the screenshot script from the test fixture's lines. The Finnish is
the test fixture's (lines 1 to 3 of `docs/risk-tests/test-2-voice-lines.md`),
not reviewed. These show the look only; the real flow is proved by the browser
tests on a throwaway database in the pull request check.

- `1-front-*.png` the front door, signed out
- `2-hear-*.png` Hear it after "Next line"
- `3-card-*.png` a word card
- `4-understand-wrong-*.png` Understand it after a wrong choice
- `5-understand-right-*.png` after the right choice
- `6-finish-*.png` the finish screen, saved

## Round 2 (22 October 2026)

Same method (Chromium, made-up answers from fixture lines, not reviewed Finnish):

- `r2-understand-667.png` and `r2-understand-667-wrong.png` Understand it at 375 x 667: the answer rows stay in view, also after a wrong answer
- `r2-hear-320.png` Hear it at 320 px: "Helsingist?" keeps its question mark, the unit goal is labelled, the status line says "Line 1 of 3."
- `r2-front-not-ready.png` the front door with nothing ready: the message sits under the heading
