// OWNER INPUT: the privacy notice's "Who is responsible" section
// (factory/jobs/11-accounts/spec.md, owner's call 2).
//
// The owner fills in both values below. No agent chooses them. Until they are
// filled in, the notice says in the problem style that they are missing, and
// a release must not happen: tests/personal-data.test.ts prints the state, and
// factory/jobs/11-accounts/build.md lists it as waiting for the owner.
//
//   responsibleName  who is responsible for the learners' data (the
//                    controller): a registered business name with its business
//                    ID, or the owner's own name
//   contact          where learners send privacy requests: an email address
//                    (or a web address) the owner chooses

export interface Responsible {
  responsibleName: string
  contact: string
}

export const RESPONSIBLE: Responsible | null = null

/** The date the notice's wording last changed, shown at its end (YYYY-MM-DD). */
export const NOTICE_UPDATED = '2026-10-22'
