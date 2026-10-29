// Downloads the learner's data file (factory/jobs/11-accounts/spec.md, "Done
// when" 18). The file comes from the app's own /api/account/export, is kept in
// the browser's memory only long enough to hand it to the browser's download,
// and is never stored by the page. Same timer pattern as src/lib/api.ts, for
// older browsers.

const DOWNLOAD_TIMEOUT_MS = 30_000

function fileNameFrom(disposition: string | null): string {
  const match = /filename="([^"]+)"/.exec(disposition ?? '')
  return match?.[1] ?? 'puhuscribe-data.json'
}

export type DownloadResult = 'ready' | 'signed_out' | 'failed'

export async function downloadMyData(): Promise<DownloadResult> {
  const controller = new AbortController()
  const timer = setTimeout(() => {
    controller.abort()
  }, DOWNLOAD_TIMEOUT_MS)
  try {
    const res = await fetch('/api/account/export', { credentials: 'same-origin', signal: controller.signal })
    if (res.status === 401) return 'signed_out'
    if (!res.ok) return 'failed'
    const blob = await res.blob()
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = fileNameFrom(res.headers.get('content-disposition'))
    document.body.append(link)
    link.click()
    link.remove()
    setTimeout(() => {
      URL.revokeObjectURL(url)
    }, 60_000)
    return 'ready'
  } catch {
    return 'failed'
  } finally {
    clearTimeout(timer)
  }
}
