// Read-only checks on the Supabase TEST project. The connection string is read
// from the worktree's .env.local inside this process and never printed.
// Every query runs inside a READ ONLY transaction, so no write is possible.
const fs = require('fs')
const { Client } = require('pg')

const envPath = 'C:/Users/fumna/dev/puhuscribe-v3/.worktrees/2-smoke/.env.local'
const line = fs
  .readFileSync(envPath, 'utf8')
  .split(/\r?\n/)
  .find((l) => /^\s*SUPABASE_DB_URL\s*=/.test(l))
if (!line) {
  console.error('SUPABASE_DB_URL not found in .env.local')
  process.exit(2)
}
let url = line.replace(/^\s*SUPABASE_DB_URL\s*=\s*/, '').trim()
if ((url.startsWith('"') && url.endsWith('"')) || (url.startsWith("'") && url.endsWith("'"))) url = url.slice(1, -1)

const mode = process.argv[2] ?? 'count'

const QUERIES = {
  count: [['visits row count', 'select count(*)::int as visits_count, now() as db_time from public.visits']],
  catalog: [
    ['current database and user', 'select current_database() as db, current_user as role, version()'],
    [
      'columns of public.visits (information_schema)',
      `select column_name, data_type, is_nullable, column_default, is_identity, identity_generation
         from information_schema.columns where table_schema='public' and table_name='visits' order by ordinal_position`,
    ],
    [
      'table grants on public.visits (information_schema.role_table_grants)',
      `select grantee, privilege_type from information_schema.role_table_grants
         where table_schema='public' and table_name='visits' order by grantee, privilege_type`,
    ],
    [
      'effective privileges per API role (has_table_privilege)',
      `select r.role,
         has_table_privilege(r.role,'public.visits','SELECT') as sel,
         has_table_privilege(r.role,'public.visits','INSERT') as ins,
         has_table_privilege(r.role,'public.visits','UPDATE') as upd,
         has_table_privilege(r.role,'public.visits','DELETE') as del,
         has_table_privilege(r.role,'public.visits','TRUNCATE') as trunc,
         has_table_privilege(r.role,'public.visits','REFERENCES') as refs,
         has_table_privilege(r.role,'public.visits','TRIGGER') as trig
       from (values ('anon'),('authenticated'),('service_role')) r(role)`,
    ],
    [
      'column-level grants on public.visits',
      `select grantee, column_name, privilege_type from information_schema.column_privileges
         where table_schema='public' and table_name='visits' and grantee in ('anon','authenticated','service_role')
         order by grantee, column_name, privilege_type`,
    ],
    [
      'sequence privileges (visits_id_seq) per API role',
      `select r.role,
         has_sequence_privilege(r.role,'public.visits_id_seq','USAGE') as usage,
         has_sequence_privilege(r.role,'public.visits_id_seq','SELECT') as sel,
         has_sequence_privilege(r.role,'public.visits_id_seq','UPDATE') as upd
       from (values ('anon'),('authenticated'),('service_role')) r(role)`,
    ],
    [
      'row level security flags (pg_class)',
      `select relname, relrowsecurity, relforcerowsecurity from pg_class where oid='public.visits'::regclass`,
    ],
    [
      'policies on public.visits (pg_policies)',
      `select policyname, permissive, roles, cmd, qual, with_check from pg_policies where schemaname='public' and tablename='visits'`,
    ],
    [
      'tables, views and functions in public schema',
      `select 'table' as kind, tablename as name from pg_tables where schemaname='public'
       union all select 'view', viewname from pg_views where schemaname='public'
       union all select 'matview', matviewname from pg_matviews where schemaname='public'
       union all select 'function', p.proname from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public'
       order by 1,2`,
    ],
    [
      'triggers on public.visits',
      `select tgname from pg_trigger where tgrelid='public.visits'::regclass and not tgisinternal`,
    ],
    ['installed extensions (pg_extension)', 'select extname, extversion from pg_extension order by extname'],
    [
      'migration history (supabase_migrations.schema_migrations)',
      `select version, name from supabase_migrations.schema_migrations order by version`,
    ],
    [
      'visits by minute, last 2 hours (only counts, no other data exists)',
      `select count(*)::int as rows_total, min(visited_at) as first_visit, max(visited_at) as last_visit from public.visits`,
    ],
  ],
}

;(async () => {
  const client = new Client({ connectionString: url, ssl: { rejectUnauthorized: false } })
  await client.connect()
  await client.query('begin transaction read only')
  for (const [label, sql] of QUERIES[mode]) {
    try {
      const res = await client.query(sql)
      console.log(`## ${label}`)
      console.table(res.rows)
    } catch (e) {
      console.log(`## ${label}\nERROR: ${e.code ?? ''} ${e.message}`)
    }
  }
  await client.query('rollback')
  await client.end()
})().catch((e) => {
  // Never print the error object as a whole: it can carry connection details.
  console.error('query failed:', e.code ?? '', String(e.message).replace(/postgres(ql)?:\/\/\S+/g, 'REDACTED'))
  process.exit(1)
})
