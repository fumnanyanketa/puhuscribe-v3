// Who processes learner data for PuhuScribe, as the privacy notice lists them
// (factory/jobs/11-accounts/spec.md, "Done when" 16 and 17). Every sentence
// comes from the spec's "Privacy notice facts" table.
//
// Every provider module in worker/providers/ (voice, speech feedback, AI) must
// be named in the `modules` of one processor here: a repository test
// (tests/personal-data.test.ts) fails otherwise, so a provider cannot ship
// without being listed in the notice. The speech fixtures file is the test
// stand in for the speech provider, so it is listed with it.

export interface Processor {
  name: string
  /** What they do for PuhuScribe. */
  role: string
  /** Where the data is. */
  where: string
  /** The worker/providers/ files (file names) that send data to them. */
  modules: readonly string[]
  /** More detail, one paragraph each, shown under `where` in the full notice (and for Anthropic, under "More about Otso"). */
  details?: readonly string[]
  /** A page of the processor's own, linked at the end of its entry. */
  link?: { label: string; href: string }
}

/**
 * Otso, the AI tutor (job 16-tutor-step, owner's call 1 of 3 November 2026: Anthropic's own API,
 * processed in the United States). The terms below are Anthropic's own pages as the manager read them
 * on 3 November 2026 (factory/todo.md, "Before real learners: Otso and Anthropic"): the Data
 * Processing Addendum with Anthropic Ireland, Limited for EEA customers, the EU Standard Contractual
 * Clauses, deletion within 30 days with flagged content kept up to 2 years, and no training on API
 * content. worker/tutor-prompt.ts builds the request from approved lesson content and the chat text
 * only; worker/providers/ai.ts adds no metadata, and the Worker, not the browser, makes the call.
 */
export const ANTHROPIC: Processor = {
  name: 'Anthropic',
  role: "Writes Aleksi's replies, only if you turned Aleksi on. It receives your chats with Aleksi as text: what you type, the text of what you say and Aleksi's earlier lines, with Aleksi's instructions and the Finnish words and lesson lines you have met. We do not save the chat.",
  where: 'In the United States.',
  details: [
    'Anthropic Ireland, Limited processes the chats as our processor, in the United States. The transfer is covered by the EU Standard Contractual Clauses.',
    'Anthropic deletes them within 30 days. Content its safety checks flag may be kept for up to 2 years.',
    'Anthropic does not use them to train its models.',
    'We add nothing that identifies you, such as your email, account or guest id, or your IP address.',
  ],
  link: { label: "Anthropic's list of sub-processors", href: 'https://trust.anthropic.com/subprocessors' },
  modules: ['ai.ts', 'fixtures/ai/index.ts'],
}

export const PROCESSORS: readonly Processor[] = [
  {
    name: 'Supabase',
    role: 'Keeps the database and handles sign in.',
    where: 'In the EU (Ireland).',
    // Crash reports go to PuhuScribe's own database (job 14-analytics).
    modules: ['crash-reports.ts'],
  },
  {
    name: 'Cloudflare',
    role: 'Runs the app and passes every request on to the database.',
    where:
      "Requests pass through Cloudflare's network, which may handle them outside the EU under its data processing terms (EU standard contractual clauses and the EU US Data Privacy Framework).",
    // Job turnstile (owner's choice, 3 November 2026). The facts are Cloudflare's Turnstile Privacy
    // Addendum (last updated 18 June 2025): the signals it lists, that Cloudflare cannot identify a
    // person from them, and that it is a processor for the bot check and a controller for improving it.
    details: [
      "When you press Start without an account, Cloudflare Turnstile checks for bots before your guest account is made. It reads your internet address, your browser's User-Agent and TLS fingerprint and this site's key and address, which Cloudflare says cannot identify you directly, and Cloudflare also uses them to improve its bot detection.",
    ],
    link: {
      label: "Cloudflare's Turnstile privacy addendum",
      href: 'https://www.cloudflare.com/turnstile-privacy-policy/',
    },
    modules: ['human-check.ts'],
  },
  {
    // Job go-live (owner's choice of 4 November 2026, factory/todo.md "Go-live address"): sign in code
    // emails go from Supabase Auth through Brevo's email servers (SMTP), from hello@meetaleksi.com. The
    // Worker never talks to Brevo, so no worker/providers/ file names it. Brevo is the trading name of
    // Sendinblue SAS, a company in France.
    name: 'Brevo',
    role: 'Sends the sign in code emails, only if you add your email. It receives your email address and the email with your code.',
    where: 'In the EU.',
    details: [
      'Sendinblue SAS, a company in France that trades as Brevo, sends these emails as our processor.',
    ],
    link: { label: "Brevo's privacy policy", href: 'https://www.brevo.com/legal/privacypolicy/' },
    modules: [],
  },
  {
    name: 'Microsoft (Azure Speech)',
    role: 'Turns your voice into text for speaking feedback, only if you turned speaking feedback on. It receives a few seconds of audio per line and does not keep it.',
    where:
      'In the EU. The voice section at the top of this notice names the country when you have an account.',
    modules: ['speech-feedback.ts', 'fixtures/speech/index.ts'],
  },
  ANTHROPIC,
]

/** How long the providers keep their own logs. */
export const PROVIDER_LOGS =
  "On the free plan Aleksi uses, Supabase keeps its API and database logs for 1 day and its sign in audit logs for 1 hour. The app's own request logs at Cloudflare are turned off."
