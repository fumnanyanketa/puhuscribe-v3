# Cost log

`ai-calls.jsonl` gets one line per AI call and per voice synthesis made by the content pipeline: the time, the provider, the purpose (`draft`, `why`, `judge` or `voice`), the model or voice, the tokens or characters, the cost in US dollars with the date of its price table, and the dialogue slug. It never holds a key or any prompt text. The file appears with the first real run. How it works: [docs/content-pipeline.md](../../docs/content-pipeline.md).
