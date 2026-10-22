import { StatusLine } from '../components/StatusLine.tsx'
import { Wordmark } from '../components/Wordmark.tsx'
import { ACCOUNT_ITEMS, HOW_LONG, USER_TABLES, type InventoryItem } from '../privacy/data-inventory.ts'
import { NOTICE_UPDATED, RESPONSIBLE, type Responsible } from '../privacy/notice-settings.ts'
import { PROCESSORS, PROVIDER_LOGS } from '../privacy/processors.ts'
import styles from './Account.module.css'

// The privacy notice, at /privacy (factory/jobs/11-accounts/spec.md, "Done
// when" 16 and 17). It loads without an account and calls no /api route.
// Every fact comes from the spec's "Privacy notice facts" table; "What we
// keep" is rendered from src/privacy/data-inventory.ts and the processors
// from src/privacy/processors.ts. The responsible name and contact come from
// src/privacy/notice-settings.ts, which only the owner fills in.

export const COMPLAINT_URL = 'https://tietosuoja.fi/en/notification-to-the-data-protection-ombudsman'
export const MISSING_RESPONSIBLE =
  'The name and contact address of the person responsible are not filled in yet. PuhuScribe is not open to learners until they are.'

export const RIGHTS = [
  'See your data and download it as one file ("Download my data" on your account page).',
  'Have your data corrected.',
  'Have your data deleted ("Delete my account" on your account page deletes everything at once).',
  'Restrict how your data is used.',
  'Object to how your data is used.',
  'Withdraw a consent you gave, at any time.',
]

export const SECTION_HEADINGS = [
  'Who is responsible',
  'What we keep and why',
  'How long we keep it',
  'Where it is kept and who processes it',
  'Cookies',
  'Your rights',
  'Age',
  'Last updated',
] as const

function formatDate(isoDate: string): string {
  return new Date(`${isoDate}T12:00:00Z`).toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC',
  })
}

function contactHref(contact: string): string {
  return contact.includes('@') && !contact.includes('://') ? `mailto:${contact}` : contact
}

function Item({ item }: { item: InventoryItem }) {
  return (
    <li className={styles.item}>
      <h3 className={styles.itemName}>{item.name}</h3>
      <p className={styles.text}>{item.what}</p>
      <p className={styles.quietText}>Why: {item.why}</p>
      <p className={styles.quietText}>Legal reason: {item.legal}</p>
    </li>
  )
}

export function PrivacyPage({ responsible = RESPONSIBLE }: { responsible?: Responsible | null }) {
  const [who, what, howLong, where, cookies, rights, age, updated] = SECTION_HEADINGS
  return (
    <main className={styles.page}>
      <div className={styles.top}>
        <Wordmark height={36} />
      </div>
      <div className={styles.intro}>
        <h1 className={styles.title}>Privacy notice</h1>
        <p className={styles.text}>
          This notice explains what PuhuScribe keeps about you and why, how long it is kept, where it is kept,
          and how to reach the person responsible.
        </p>
      </div>

      <div className={styles.notice}>
        <section className={styles.section} aria-labelledby="privacy-who">
          <h2 id="privacy-who" className={styles.heading}>
            {who}
          </h2>
          {responsible ? (
            <>
              <p className={styles.text}>
                {responsible.responsibleName} is responsible for your data in PuhuScribe.
              </p>
              <p className={styles.text}>Send questions and privacy requests to:</p>
              <ul className={styles.links}>
                <li>
                  <a className={styles.link} href={contactHref(responsible.contact)}>
                    {responsible.contact}
                  </a>
                </li>
              </ul>
            </>
          ) : (
            <StatusLine tone="problem">{MISSING_RESPONSIBLE}</StatusLine>
          )}
        </section>

        <section className={styles.section} aria-labelledby="privacy-what">
          <h2 id="privacy-what" className={styles.heading}>
            {what}
          </h2>
          <ul className={styles.list} data-inventory="account">
            {ACCOUNT_ITEMS.map((item) => (
              <Item key={item.name} item={item} />
            ))}
          </ul>
          <p className={styles.text}>Your learning progress:</p>
          <ul className={styles.list} data-inventory="tables">
            {USER_TABLES.map((item) => (
              <Item key={item.table} item={item} />
            ))}
          </ul>
        </section>

        <section className={styles.section} aria-labelledby="privacy-how-long">
          <h2 id="privacy-how-long" className={styles.heading}>
            {howLong}
          </h2>
          <p className={styles.text}>{HOW_LONG}</p>
        </section>

        <section className={styles.section} aria-labelledby="privacy-where">
          <h2 id="privacy-where" className={styles.heading}>
            {where}
          </h2>
          <ul className={styles.list}>
            {PROCESSORS.map((processor) => (
              <li key={processor.name} className={styles.item}>
                <h3 className={styles.itemName}>{processor.name}</h3>
                <p className={styles.text}>{processor.role}</p>
                <p className={styles.quietText}>{processor.where}</p>
              </li>
            ))}
          </ul>
          <p className={styles.text}>{PROVIDER_LOGS}</p>
        </section>

        <section className={styles.section} aria-labelledby="privacy-cookies">
          <h2 id="privacy-cookies" className={styles.heading}>
            {cookies}
          </h2>
          <p className={styles.text}>
            PuhuScribe uses only the sign in cookies it needs to work. It uses no tracking or advertising
            cookies.
          </p>
        </section>

        <section className={styles.section} aria-labelledby="privacy-rights">
          <h2 id="privacy-rights" className={styles.heading}>
            {rights}
          </h2>
          <p className={styles.text}>You have the right to:</p>
          <ul className={styles.list}>
            {RIGHTS.map((right) => (
              <li key={right} className={styles.text}>
                {right}
              </li>
            ))}
          </ul>
          <p className={styles.text}>
            For anything you cannot do in the app, write to the contact address above. Requests are answered
            within one month.
          </p>
          <p className={styles.text}>
            You can also complain to Finland&apos;s Office of the Data Protection Ombudsman:
          </p>
          <ul className={styles.links}>
            <li>
              <a className={styles.link} href={COMPLAINT_URL} rel="noreferrer">
                Make a complaint to the Data Protection Ombudsman
              </a>
            </li>
          </ul>
        </section>

        <section className={styles.section} aria-labelledby="privacy-age">
          <h2 id="privacy-age" className={styles.heading}>
            {age}
          </h2>
          <p className={styles.text}>PuhuScribe is for adults, 18 and over.</p>
        </section>

        <section className={styles.section} aria-labelledby="privacy-updated">
          <h2 id="privacy-updated" className={styles.heading}>
            {updated}
          </h2>
          <p className={styles.text}>This notice was last updated on {formatDate(NOTICE_UPDATED)}.</p>
        </section>
      </div>

      <ul className={styles.links}>
        <li>
          <a className={styles.link} href="/account">
            Your account
          </a>
        </li>
        <li>
          <a className={styles.link} href="/">
            Back to the start
          </a>
        </li>
      </ul>
    </main>
  )
}
