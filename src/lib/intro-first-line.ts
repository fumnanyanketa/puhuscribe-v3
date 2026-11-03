// The audio the recap card's play button plays: the spoken (puhekieli) first
// line of the first dialogue a new learner meets, "A new colleague", line 1 of
// stop 1 (the owner's fast route plan of 3 November 2026, "intro", item 2).
//
// It is a static file the app already serves from its own address, published
// and approved with the dialogue (supabase/migrations/
// 20261102000000_publish_meeting_people_new_colleague.sql, content/approvals/
// part-1.json). Before Start there is no session to ask, and GET /api/road
// carries no Finnish by design, so the path is named here.
// tests/intro-first-line.test.ts fails if a migration changes which dialogue
// comes first, if the line's audio key changes, or if the file is missing.

export const FIRST_DIALOGUE_SLUG = 'meeting-people-new-colleague'
export const FIRST_LINE_AUDIO_KEY = 'meeting-people-new-colleague/1-puhe-b05a09885e3a.mp3'
export const FIRST_LINE_AUDIO = `/audio/${FIRST_LINE_AUDIO_KEY}`
