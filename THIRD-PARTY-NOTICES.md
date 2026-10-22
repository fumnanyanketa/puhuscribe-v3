This repository has no licence yet: the owner has not chosen one, so there is no root LICENSE file. This file lists only the material that other people made and that carries its own licence.

# Third party notices

## Agent skills from jsmastery-pro/skills (MIT License)

These skills in `.claude/skills/` were installed from the public repository `jsmastery-pro/skills` on GitHub (https://github.com/jsmastery-pro/skills). `skills-lock.json` records the source and a hash for each one.

- `architect`
- `audit`
- `check`
- `debug`
- `develop`
- `document`
- `scope`
- `sync`
- `test`

The upstream repository publishes these skills under the MIT License. The copied files in this repository do not carry the copyright holder's name or a licence text, so the copyright line is not repeated here. The holder named in the upstream repository applies: see the upstream repository at https://github.com/jsmastery-pro/skills.

The MIT License permission notice, which applies to those skills:

> MIT License
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The other skills in `.claude/skills/` (`canvas`, `factory`, `liftoff`, `warden`) are not listed in `skills-lock.json`, so this file makes no claim about their origin.

## Word frequency list (CC BY-SA 4.0)

- **File.** `data/finnish_frequency_lemmas.json`
- **Source.** Frequency data from wordfreq's "large" Finnish data, which blends several corpora. The file's own metadata also credits the SUBTLEX authors (Brysbaert, New, Keuleers et al.). Lemmatisation and validation use Voikko (https://voikko.puimula.org).
- **Licence.** The wordfreq README says its data is CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/). The file's own metadata credits only "wordfreq (MIT)", which covers wordfreq's code. This notice follows the data licence, the stricter one.
- **Changes.** Made in PuhuScribe v2 from the full wordfreq Finnish list: every word form was analysed with Voikko, forms that are not valid Finnish words, proper nouns, abbreviations and single letters were removed, forms were grouped under their lemma (dictionary form), and the 10,000 most frequent lemmas were kept.
- **Use.** Build-time only. It chooses which words a brief may use and is not shown to learners (`docs/content-attribution.md`).
- **ShareAlike.** Anyone may reuse this file under CC BY-SA 4.0, and any adaptation of it must be shared under the same licence.

## Finnish pronunciation (IPA) data from English Wiktionary (CC BY-SA 4.0)

- **Files.**
  - `content/v2-starter/from-v2/20260607000003_word_ipa_from_kaikki.sql`
  - `supabase/migrations/20261020090300_load_v2_lemma_ipa.sql`
- **Source.** English Wiktionary, via kaikki.org. Attribution line: "Definitions and IPA from English Wiktionary via kaikki.org, CC BY-SA 4.0."
- **Licence.** CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/).
- **Changes.** The first file, made in PuhuScribe v2, turns the IPA that kaikki.org provides into SQL statements. The second file, made in this project, loads the IPA of 514 Finnish base forms from the first file into the `lemma_ipa` table. No IPA was invented or edited.
- **Use.** Reference data in the database. No learner can read it today. Showing it to learners needs the attribution line above (`docs/content-attribution.md`).
- **ShareAlike.** Anyone may reuse these two files under CC BY-SA 4.0, and any adaptation of them must be shared under the same licence.
