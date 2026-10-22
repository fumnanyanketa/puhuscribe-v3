// Who processes learner data for PuhuScribe, as the privacy notice lists them
// (factory/jobs/11-accounts/spec.md, "Done when" 16 and 17). Every sentence
// comes from the spec's "Privacy notice facts" table.
//
// Every provider module in worker/providers/ (voice, speech feedback, AI) must
// be named in the `modules` of one processor here: a repository test
// (tests/personal-data.test.ts) fails otherwise, so a provider cannot ship
// without being listed in the notice.

export interface Processor {
  name: string
  /** What they do for PuhuScribe. */
  role: string
  /** Where the data is. */
  where: string
  /** The worker/providers/ files (file names) that send data to them. */
  modules: readonly string[]
}

export const PROCESSORS: readonly Processor[] = [
  {
    name: 'Supabase',
    role: 'Keeps the database and handles sign in. Until PuhuScribe chooses its own email sender, Supabase also sends the sign in code emails.',
    where: 'In the EU (Ireland).',
    modules: [],
  },
  {
    name: 'Cloudflare',
    role: 'Runs the app and passes every request on to the database.',
    where:
      "Requests pass through Cloudflare's network, which may handle them outside the EU under its data processing terms (EU standard contractual clauses and the EU US Data Privacy Framework).",
    modules: [],
  },
]

/** How long the providers keep their own logs. */
export const PROVIDER_LOGS =
  "On the free plan PuhuScribe uses, Supabase keeps its API and database logs for 1 day and its sign in audit logs for 1 hour. The app's own request logs at Cloudflare are turned off."
