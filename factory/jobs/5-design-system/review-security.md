# Job 5-design-system: security and privacy review, round 1

Reviewed branch `factory/5-design-system` at 0f94502 (PR #12) against main, in `.worktrees/5-design-system`. I read AGENTS.md, spec.md, summary.md and build.md, then the full diff. I did not open any `.env*` file and made no call to Cloudflare or Supabase. I ran `npm audit` (0 vulnerabilities) and checked with `gh` that the repository is private.

This job adds no learner data, no database change, no Worker or API change and no AI, voice or speech call. Recording is look only: nothing in `src/` calls `getUserMedia` or `mediaDevices`.

## Findings

No must fix findings.

1. **Note.** `src/main.tsx:17`. The design pages are left out only when the build runs without `VITE_DESIGN_REFERENCE=1`. No production build pipeline exists yet (the Worker is `puhuscribe-preview`; liftoff creates the live one). If a later production build runs on a machine whose `.env.local` sets the variable to 1, Vite reads that file and the unreviewed sample Finnish ships to learners. Fix at liftoff: the production build step sets `VITE_DESIGN_REFERENCE: '0'` in its environment, as `tests/design-build.test.ts:33` already does, and fails if a `DesignReference` or `HearItSample` file appears in the built `client/` folder.
2. **Note.** `tests/design-build.test.ts:53-54`. The markers "Could not play" and "Stop recording" come from the shared `PlayControl` and `RecordControl`, not from the design pages. When job 6 puts those parts in the learner app, this test will go red even though nothing leaked. A builder might then weaken the check. Fix in job 6: replace these two markers with text found only on the design pages, and keep the file name check on line 70.
3. **Note.** `.gitattributes:31`. `src/assets/fonts/** binary` marks every file in that folder as binary, including the text licence `FFL.txt`. gitleaks scans commit patches and skips binary files, so it would miss a secret pasted into a text file there. The SHA-256 test pins the contents of `switzer/` only. Fix if you want it closed: limit the rule to `src/assets/fonts/**/*.woff2 binary` and add `src/assets/fonts/**/*.txt -text`, so line endings stay unchanged and the licence still shows in diffs. Then update the attribute test in `tests/design-rules.test.ts:46`.
4. **Note.** `tests/design-build.test.ts:28-36`. The local build goes into a folder under the system temp directory, and its Worker side can hold a copy of `.env.local`, as the test's own comment says. `afterAll` deletes it. If the run is stopped by force (Ctrl+C or a crash), a copy of the local test settings stays in `%TEMP%`. The risk is low because the folder is in the owner's own profile and holds test project values only. Fix if wanted: pass the build a setting so the Worker output is skipped, or delete the Worker folder right after the build.

## Checked and found sound

- **Gating.** `designPagesOn` is a build-time constant. A production build replaces it with `false` and drops both lazy imports. The build test forces `NODE_ENV=production` and `VITE_DESIGN_REFERENCE=0` in the process environment, which overrides any `.env` file. The red run in `evidence/red-run-round2-build.txt` shows the test catching a forced-on build. In a normal build, `/design-reference` falls through to the Hei! page.
- **checks.yml.** The variable is set only in the browser test job (lines 254 to 257) and the pull request preview job (lines 362 to 365). Neither deploys to a live address. The preview upload is a version alias behind Cloudflare Access. No secret was added and no secret step changed.
- **v2 handoff (`design/v2-handoff/`).** It is not imported, bundled or type checked. `tsconfig.app.json` includes only `src`, and Vite builds only from `index.html`. The HTML file loads React and Babel from unpkg with subresource integrity hashes, and its `tokens.css` imports Google Fonts and Fontshare. That happens only if someone opens the file by hand. It contains no keys or personal data, only a `you@example.com` placeholder.
- **Fonts.** Every `@font-face` and `@fontsource` import resolves to the app's own address. The smoke test now requires every stylesheet and font request to come from the app's own address. Section 01 of the ITF licence allows self-hosting for your own websites and apps. The repository is private, as the licence requires.
- **Dependencies.** `@fontsource/poppins` 5.3.0 is a runtime package of font files and CSS only, OFL 1.1. `@axe-core/playwright` 4.14.0 is development only, MPL 2.0, from Deque. Both are pinned exactly, with lockfile integrity hashes from registry.npmjs.org. `axe-core` 4.14.0 was already in the lockfile. `npm audit` finds no vulnerabilities.
- **Play control.** `preload = 'none'`. The audio element is created only inside the press handler, so nothing is fetched or played before a tap or key press. There is no `autoplay`. The reference page plays only blob URLs it generates itself and one deliberately broken data URL.
- **Record control.** It only shows states. Nothing asks for the microphone, which a test enforces.
- **Word card.** It is a native `<dialog>` opened with `showModal()`, so the page behind is inert. Escape is handled through `cancel`, and the scroll lock is restored on close. All Finnish and English text is rendered as React text. There is no `dangerouslySetInnerHTML`, `innerHTML`, `eval` or URL handling anywhere in the new code, so no XSS path exists.
- **Evidence files.** These are screenshots and red run logs with local temp paths only. They hold no secrets or headers.

## For the owner to look at closely

- **The production build at liftoff (finding 1).** The design pages stay out of the live app only if the live build runs without `VITE_DESIGN_REFERENCE=1`. Please check that `.env.example` (which this job changed and which I did not open) shows the variable empty or commented out, never set to 1.
- **`@axe-core/playwright`.** It was published 6 days before this review. It runs in the preview job's browser test step, which holds the Cloudflare Access service token. The publisher is reputable and the version is pinned, but it is a fresh release in a step that holds a secret.
- **Switzer in a public repository.** Switzer's licence forbids sharing the font files through a publicly accessible repository. If this repository is ever made public, the files in `src/assets/fonts/switzer/` must first leave git, including its history. `design.md` already says so.

Result: pass
