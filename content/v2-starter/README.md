# v2 starter data

Reference data from PuhuScribe v2, loaded into the closed reference tables by `scripts/v2-import/`. How it works and how to load it again: [docs/data-model.md](../../docs/data-model.md#loading-v2s-data-again).

- `from-v2/`: byte for byte copies of v2 files at commit `9c8d0a083d6209e0135efe20f88db99ff9c867e4`. Do not edit them.
- `corrections.tsv`: the native reviewer's corrections to v2's 104 starter sentences, one tab separated row per change (`sentence`, `register`, `before`, `after`). It holds only the header line until the owner's marked up list arrives.
