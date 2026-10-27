// The privacy notice's "Who is responsible" section (owner's call 2, answered
// by the owner on 27 October 2026). This file is the one place the name and
// the contact address live. If the address changes, change it here only.
//
//   responsibleName  who is responsible for the learners' data (the controller)
//   contact          where learners send privacy requests: an email address

export interface Responsible {
  responsibleName: string
  contact: string
}

export const RESPONSIBLE: Responsible = {
  responsibleName: 'Fumnanya Nketa',
  contact: 'exentrik.co@gmail.com',
}

/** The date the notice's wording last changed, shown at its end (YYYY-MM-DD). */
export const NOTICE_UPDATED = '2026-10-22'
