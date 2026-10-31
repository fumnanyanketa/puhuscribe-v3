// The words of the welcome on the front door (factory/jobs/15-onboarding/spec.md,
// "Done when" 2 and 4). Every piece of text the welcome shows is held here and
// nowhere else, so the owner can edit it at approval and
// src/screens/welcome-copy.test.ts holds the new words to the same rules: at
// most 80 words, the writing rules of AGENTS.md, and no Finnish.
//
// There is no Finnish in the welcome (owner's call 5, option A). The labels
// are the English ones the Hear it screen uses.

export const WELCOME_HEADING = 'Welcome to PuhuScribe'

export const WELCOME_SESSION =
  'You tap any word to see what it is, and you say the lines back. The words you met come back for review on later days.'

export const WELCOME_TWO_FORMS = 'Every line comes in two forms, and you can hear both.'

export const WELCOME_SPOKEN_LABEL = 'Spoken'
export const WELCOME_SPOKEN = 'How people in Finland talk day to day, in shops and at work.'

export const WELCOME_WRITTEN_LABEL = 'Written'
export const WELCOME_WRITTEN = 'How Finnish is written in books and on forms.'

export const WELCOME_ORDER = 'Spoken comes first. The written form sits under it.'
