# Fonts

The app uses two fonts. Poppins comes from npm and needs nothing special. Switzer is not in this repository, and this page explains why and what happens without it.

## Why Switzer is not here

Switzer (body text) is licensed under the ITF Free Font License. The licence allows commercial use and self hosting on our own servers. It forbids making the font files available through a public repository. This repository is public, so the files are kept out of it and out of its history.

## What the app does without the files

Nothing breaks. The body font stack in `src/styles/tokens.css` is `'Switzer', 'Poppins', system-ui, sans-serif`, so the body text falls back to Poppins. Headings and Finnish lines use Poppins already. `npm ci`, `npm run check:code`, `npm test` and `npm run build` all pass without the files.

The tests that look at Switzer itself skip, and say why:

- `tests/design-rules.test.ts`: the two tests of the Switzer files (byte for byte as downloaded, and how git treats them). Their names end with "skipped while the Switzer files are absent".
- `e2e/design-reference.spec.ts` and `e2e/design-sample.spec.ts`: one test each that checks ä, ö, å render in Switzer and that the body text uses it. They skip with the reason printed by `e2e/switzer.ts`.

They run as normal when the files are present. Nothing was deleted or loosened. Two tests that always run protect the arrangement: the files are not tracked by git, and the app falls back to Poppins.

## How the files get in

`scripts/ci/fetch-private-fonts.ts` fills `src/assets/fonts/switzer/` and writes `switzer.css` there, which holds the `@font-face` rules. `src/main.tsx` imports that CSS only when it exists, so a checkout without the files never asks for them. Git ignores the folder.

The script takes the files from the first source that works:

1. The folder already holds them, matching the SHA-256 values on record. Nothing to do.
2. `FONTS_SOURCE_DIR`: a local folder with the files, for a computer that has them.
3. `FONTS_DEPLOY_KEY`: a read only deploy key (an SSH key that can read one repository) for the private fonts repository. `FONTS_REPO` is that repository's SSH address. The default is `git@github.com:fumnanyanketa/puhuscribe-v3-fonts.git`. The repository holds the four WOFF2 files and `FFL.txt`, at its top level or in a `switzer/` folder.
4. Neither: the script prints a notice and the build goes on with the fallback.

The script refuses any file whose SHA-256 differs from the downloaded original, because the licence forbids changing the files. It never fails the build over missing fonts, and it never prints the key.

## Setting it up in GitHub

1. Create a private repository for the fonts (the default name above, or any name set in `FONTS_REPO`) and put `Switzer-Regular.woff2`, `Switzer-Medium.woff2`, `Switzer-Semibold.woff2`, `Switzer-Bold.woff2` and `FFL.txt` in it. Take them from fontshare.com.
2. Make an SSH key pair, add the public half to that repository as a read only deploy key, and store the private half in this repository's secret `FONTS_DEPLOY_KEY`.
3. The workflow `.github/workflows/checks.yml` runs the script after `npm ci` in the job that tests against the test project after a merge and in the preview job. Both then build and test with Switzer. The throwaway database browser job holds no secret by design, so it runs without Switzer and skips the Switzer tests.

Without the secret, those jobs print a notice and carry on with the fallback.

## On your own computer

Run `FONTS_SOURCE_DIR=<folder with the files> node scripts/ci/fetch-private-fonts.ts`, or copy the five files into `src/assets/fonts/switzer/` yourself and run the script once to write `switzer.css`. Never commit the folder; git ignores it.
