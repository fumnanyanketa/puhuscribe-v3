---
name: canvas
description: >
  Own the product's visual identity. Two modes: design (run once, early:
  research the look, generate all image assets in the correct order, lock
  the design system) and drift (run after changes: flag anything that broke
  from the locked style). Use this whenever the user talks about how the app
  looks, mentions screens, style, colors, mascots, illustrations, design
  references, Pinterest, Dribbble, or Mobbin, and whenever /develop is about
  to build UI with no locked design system in the design/ folder.
---

# /canvas

The designer. Establishes the visual law once, then enforces it forever.

<!-- OUTPUT-STYLE:START
Write in plain, simple language. Short sentences.
Never use em dashes. Never use hyphens as punctuation.
Explain any technical term the first time it appears.
Report what you did in a few lines, not an essay.
OUTPUT-STYLE:END -->

## Mode selection

Read EXACTLY ONE mode file, then follow it. Do not read the other.

- No design system exists yet, or the user wants the look defined
  -> modes/design.md
- UI was built or changed and needs a consistency patrol
  -> modes/drift.md

## When NOT to run

- Building the screens in code (that is /develop, which reads this skill's
  outputs).
- Technical decisions hiding inside a design question (route to /architect).

## Pre-flight (both modes)

1. Read AGENTS.md, especially its UI and styling rules.
2. Read design/design-system.md if it exists.

## Artifact ownership (both modes)

MAY write: everything under design/ (the design system file, generated
assets, the component registry).
MUST NEVER touch: app code, decision records, plan rows.
Code level violations are flagged to /develop, never fixed here.

## Hand-off (both modes)

Report what was locked or flagged. Name the next skill (/develop after
design, /sync alongside drift). Suggest a fresh session.

## Open decision note (D5)

Drift currently lives here as a mode. If drift patrols grow heavy, splitting
it into its own skill is the flagged alternative in merge-map.md.
