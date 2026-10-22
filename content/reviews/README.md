# Review files

The native reviewer's returned files, one folder per dialogue: `content/reviews/<dialogue-slug>/round-<n>.json`.

Only the manager adds files here, on the owner's instruction, and the job summary lists each file with its date for the owner to confirm. An agent never writes a review file. The pipeline refuses a file whose items or fingerprints do not match the page the reviewer saw, and a publish migration's `approval_ref` points at the file path plus the item id. How it works: [docs/content-pipeline.md](../../docs/content-pipeline.md).
