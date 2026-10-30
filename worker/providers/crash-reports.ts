import type { CrashFrame } from '../../src/lib/crash-clean.ts'
import { supabaseSettings, type Fetch, type SupabaseEnv } from '../learner-auth.ts'

// Where crash reports go (factory/jobs/14-analytics/spec.md, "Done when" 28;
// owner's call 1, option A: PuhuScribe's own EU Supabase database). This is
// the only file that knows: it calls public.report_crash with the publishable
// key as anon, never with a sign in. Moving to another crash service changes
// this file only. tests/analytics-rules.test.ts fails if another file calls
// report_crash.
//
// It receives a report that is already cleaned (worker/crash.ts) and adds
// nothing. It never throws and writes nothing to the log.

export interface CleanCrashReport {
  source: 'browser' | 'worker'
  name: string
  message: string
  frames: CrashFrame[]
  path: string
  appVersion: string
  browser: string
}

const TIMEOUT_MS = 3000

/** Sends one report. True when the database stored it; false when it was dropped, refused or not reachable. */
export async function sendCrashReport(
  env: SupabaseEnv,
  fetchImpl: Fetch,
  report: CleanCrashReport,
): Promise<boolean> {
  const settings = supabaseSettings(env)
  if (!settings) return false
  const controller = new AbortController()
  const timer = setTimeout(() => {
    controller.abort()
  }, TIMEOUT_MS)
  try {
    const res = await fetchImpl(`${settings.url}/rest/v1/rpc/report_crash`, {
      method: 'POST',
      headers: { apikey: settings.key, 'content-type': 'application/json' },
      body: JSON.stringify({
        p_source: report.source,
        p_name: report.name,
        p_message: report.message,
        p_frames: report.frames,
        p_path: report.path,
        p_app_version: report.appVersion,
        p_browser: report.browser,
      }),
      signal: controller.signal,
    })
    if (!res.ok) {
      await res.body?.cancel()
      return false
    }
    return (await res.json()) === true
  } catch {
    return false
  } finally {
    clearTimeout(timer)
  }
}
