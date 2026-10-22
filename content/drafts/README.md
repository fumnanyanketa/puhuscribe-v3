# Drafts

One folder per dialogue, `content/drafts/<dialogue-slug>/`, holding the review pack from the "Content pipeline" workflow: `draft.json`, `check-report.json`, `audio/`, `review/` (each round's page and the list of items it asked about) and `run.log`. The Python check runs the automatic checks on every draft here on every pull request. How it works: [docs/content-pipeline.md](../../docs/content-pipeline.md).
