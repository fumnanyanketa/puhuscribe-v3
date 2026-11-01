import { useEffect, useRef, useState } from 'react'
import { Button } from '../components/Button.tsx'
import { StatusLine } from '../components/StatusLine.tsx'
import { PageFrame } from '../components/PageFrame.tsx'
import { PATHS } from '../lib/app-paths.ts'
import { emailSignInEnded, leaveWith } from '../lib/account-notice.ts'
import { callApi, isRecord } from '../lib/api.ts'
import { NO_ACCOUNT } from './AccountPage.tsx'
import styles from './Account.module.css'

// The delete confirmation, at /account/delete (factory/jobs/11-accounts/spec.md,
// "Done when" 20 and 23). Confirming deletes the account and everything saved
// with it; the front door then says so.

export const DELETE_TEXT =
  'This deletes your account and everything saved with it, including your progress and any recordings. It cannot be undone. Download your data first if you want a copy.'
export const NOT_DELETED = 'Your account was not deleted. Check your internet connection, then try again.'
const LOADING = 'Loading your account.'

type View = 'loading' | 'confirm' | 'none'

export function DeletePage() {
  const [view, setView] = useState<View>('loading')
  const [busy, setBusy] = useState(false)
  const [failed, setFailed] = useState(false)
  const status = useRef<HTMLParagraphElement>(null)
  const firstLook = useRef<Promise<View> | null>(null)

  useEffect(() => {
    let active = true
    firstLook.current ??= callApi('/api/me', 'GET').then((answer) => {
      const kind = answer?.status === 200 && isRecord(answer.body) ? answer.body.kind : 'none'
      return kind === 'guest' || kind === 'email' ? 'confirm' : 'none'
    })
    void firstLook.current.then((next) => {
      if (active) setView(next)
    })
    return () => {
      active = false
    }
  }, [])

  async function deleteAccount() {
    setBusy(true)
    setFailed(false)
    const answer = await callApi('/api/account/delete', 'POST')
    if (answer?.status === 200) {
      leaveWith('deleted')
      return
    }
    if (emailSignInEnded(answer)) {
      leaveWith('signed-out-email')
      return
    }
    if (answer?.status === 401) {
      window.location.assign(PATHS.home)
      return
    }
    setBusy(false)
    setFailed(true)
    status.current?.focus()
  }

  return (
    <PageFrame back={PATHS.account} backLabel="Back to your account">
      <div className={styles.sheet}>
        <h1 className={styles.sheetTitle}>Delete your account?</h1>
        {view === 'confirm' && <p className={styles.sheetText}>{DELETE_TEXT}</p>}
        {view === 'none' && <p className={styles.sheetText}>{NO_ACCOUNT}</p>}
        {view === 'confirm' && (
          <>
            <Button
              block
              variant="danger"
              busy={busy}
              busyLabel="Deleting your account."
              onClick={() => void deleteAccount()}
            >
              Delete for good
            </Button>
            <Button
              variant="secondary"
              block
              onClick={() => {
                window.location.assign(PATHS.account)
              }}
            >
              Keep my account
            </Button>
          </>
        )}
        <StatusLine ref={status} tone={failed ? 'problem' : 'neutral'}>
          {view === 'loading' ? LOADING : failed ? NOT_DELETED : ''}
        </StatusLine>
        {view === 'none' && (
          <a className={styles.smallLink} href={PATHS.home}>
            Back to the road
          </a>
        )}
      </div>
    </PageFrame>
  )
}
