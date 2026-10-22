---
name: canvas
description: >
  Research the product's visual direction and generate every image asset in
  the right order: the signature brand element (logo, mascot, hero) first,
  then every illustration in that style, then the empty, success and error
  state images. Use this once, early, before the first screen is built, and
  again whenever a new screen needs illustrations. Use it whenever the user
  talks about how the app should look, mentions mascots, illustrations,
  design references, Pinterest, Dribbble or Mobbin. It does NOT write
  design.md or CSS tokens; /develop owns those.
---

# /canvas

The illustrator. Finds the look with you and produces the image assets.
Project extra, kept beside the released kit. One mode only.

<!-- OUTPUT-STYLE:START -->
Write everything this skill produces, files and messages alike, in plain simple language. Talk to the reader as `you`, warm and direct like a colleague, and present every step as a recommendation they may run or skip, never an order. Keep technical terms that carry real meaning; explain each in plain words. Never use a dash or a hyphen as punctuation: no em dash, no en dash, and no hyphenated compounds. Code, file paths, command flags, and values other skills match on keep their hyphens. Use short sentences, commas, or parentheses. Clear beats clever.
<!-- OUTPUT-STYLE:END -->

## Where it sits in the workflow

- /develop owns the design system: `design.md` (art direction) and the
  token values in CSS. When /develop creates a design system it reads
  `design/brief.md` from this skill as its reference, if it exists.
- This skill owns the images under `design/assets/` and the one page
  `design/brief.md` that records the chosen direction and references.
- UI consistency after the fact is checked by `/check review` against
  `design.md`. There is no drift mode here.

## When NOT to run

- Building screens in code (that is /develop).
- Picking colors, type scale, spacing, or contrast rules (that is /develop
  creating `design.md`, which computes contrast before writing CSS).
- Technical decisions hiding inside a design question (route to /architect).

## Pre-flight

1. Read AGENTS.md, especially any UI and asset rules.
2. Read `design.md` and `design/brief.md` if they exist. If `design.md`
   exists, every asset must match its stated character.

## The work

Read `modes/design.md` and follow it.

## Artifact ownership

MAY write: `design/brief.md`, everything under `design/assets/`.
MUST NEVER touch: `design.md`, CSS, app code, specs, the scope.
Flag mismatches between assets and `design.md` to /develop.

## Hand-off

Headline: the one sentence direction and the asset count. Next: `/develop`
for the first screen (it will create `design.md` from the brief). Point to
`design/brief.md` for the detail. Suggest `/clear`.
