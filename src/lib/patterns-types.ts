// The shape of GET /api/patterns, the "Patterns you've seen" panel
// (factory/jobs/12-units-1-3/spec.md, "Done when" 10 to 14). Shared by
// worker/ and src/. Nothing here identifies the learner: no user id, no card
// scheduling numbers, and of the audio only the line's two /audio/ paths.

/** The line where the learner met a form, in both registers. */
export interface PatternLine {
  spoken: string
  written: string
  /** Same address paths of the line's audio, such as /audio/<key>. */
  spokenAudio: string
  writtenAudio: string
}

/** One approved form the learner has met. */
export interface PatternForm {
  /** The base form (forms.lemma). */
  lemma: string
  /** The spoken shape (forms.surface_puhe). */
  spoken: string
  /** The written shape (forms.surface_kirja). */
  written: string
  /** The stored "why" line (forms.why_en). */
  why: string
  line: PatternLine
}

/** Every met form with one form name (forms.form_name_en). */
export interface PatternGroup {
  formName: string
  forms: PatternForm[]
}

/** The answer of GET /api/patterns. */
export interface PatternsAnswer {
  groups: PatternGroup[]
}
