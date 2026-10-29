import type { LearnerClient } from './learner-auth.ts'
import { DatabaseUnavailable } from './learner-db.ts'

// The database calls of accounts and personal data, made with the learner's
// own token (factory/jobs/11-accounts/spec.md, "Done when" 3, 19 and 21). None
// takes a user id: each database function acts on the id in the token.
// The routes use the AccountDb interface, so their unit tests can use a fake.

export interface Account {
  id: string
  email: string | null
  isAnonymous: boolean
  createdAt: string
  lastSignInAt: string | null
  emailConfirmedAt: string | null
}

export interface AccountDb {
  /** public.my_account(): the caller's account, or null when the sign in is no longer live. */
  myAccount: () => Promise<Account | null>
  /** public.export_my_data()->'tables': one list of rows per user table. */
  exportMyData: () => Promise<Record<string, unknown[]>>
  /** public.delete_my_account(): "not_live" when the database refused a signed out token. */
  deleteMyAccount: () => Promise<'deleted' | 'not_live'>
}

interface AccountRecord {
  id: string
  email: string | null
  is_anonymous: boolean
  created_at: string
  last_sign_in_at: string | null
  email_confirmed_at: string | null
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
}

export function supabaseAccountDb(client: LearnerClient): AccountDb {
  return {
    async myAccount() {
      const { data, error } = await client.rpc('my_account')
      if (error) throw new DatabaseUnavailable()
      const row = (data as AccountRecord[] | null)?.[0]
      if (!row) return null
      return {
        id: row.id,
        email: row.email,
        isAnonymous: row.is_anonymous,
        createdAt: row.created_at,
        lastSignInAt: row.last_sign_in_at,
        emailConfirmedAt: row.email_confirmed_at,
      }
    },

    async exportMyData() {
      const { data, error } = await client.rpc('export_my_data')
      if (error || !isRecord(data) || !isRecord(data.tables)) throw new DatabaseUnavailable()
      const tables: Record<string, unknown[]> = {}
      for (const [name, rows] of Object.entries(data.tables)) {
        if (!Array.isArray(rows)) throw new DatabaseUnavailable()
        tables[name] = rows
      }
      return tables
    },

    async deleteMyAccount() {
      const { error } = await client.rpc('delete_my_account')
      if (!error) return 'deleted'
      if (error.code === '28000') return 'not_live'
      throw new DatabaseUnavailable()
    },
  }
}
